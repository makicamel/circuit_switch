require 'redis'

module CircuitSwitch
  class Store
    BASE_KEY = 'circuit_switch'.freeze

    attr_accessor :key, :caller, :run_count, :run_limit_count, :run_is_terminated, :report_count, :report_limit_count, :report_is_terminated, :due_date, :created_at, :updated_at
    def initialize(key: nil, caller: nil, run_count: 0, run_limit_count: 10, run_is_terminated: false, report_count: 0, report_limit_count: 10, report_is_terminated: false, due_date: nil, created_at: Time.current, updated_at: Time.current)
      @key = key || caller
      @caller = caller
      @run_count = run_count
      @run_limit_count = run_limit_count
      @run_is_terminated = run_is_terminated
      @report_count = report_count
      @report_limit_count = report_limit_count
      @report_is_terminated = report_is_terminated
      @due_date = due_date
      @created_at = created_at
      @updated_at = updated_at
    end

    def to_h
      {
        key: key,
        caller: caller,
        run_count: run_count,
        run_limit_count: run_limit_count,
        run_is_terminated: run_is_terminated,
        report_count: report_count,
        report_limit_count: report_limit_count,
        report_is_terminated: report_is_terminated,
        due_date: due_date,
        created_at: created_at,
        updated_at: updated_at
      }
    end

    def model_name
      'circuit_switch'
    end

    def to_model
      self
    end

    class << self
      def find(key)
        find_by(key: key)
      end

      def find_by(key: nil, caller: nil)
        key ||= caller
        raise ArgumentError, 'key or caller is required' unless key

        redis_key = "#{BASE_KEY}.#{key}"
        redis_hash = redis.hgetall(redis_key)
        if redis_hash.empty?
          nil
        else
          new(**convert_hash_from_redis(redis_hash))
        end
      end

      def find_or_initialize_by(key: nil, caller: nil)
        find_by(key: key, caller: caller) || new(key: key, caller: caller)
      end

      def empty?
        redis.keys("#{BASE_KEY}.*").empty?
      end

      def all
        redis.keys("#{BASE_KEY}.*").map do |key|
          new(**convert_hash_from_redis(redis.hgetall(key)))
        end
      end

      def redis
        @redis ||= Redis.new
      end

      private

      def convert_hash_from_redis(hash)
        hash.to_h do |k, v|
          key = k.to_sym
          value = case key
          when /_count$/
            v.to_i
          when /_terminated/
            v == "true" ? true : false
          when :due_date
            Time.parse(v)
          else
            v.to_s
          end
          [key, value]
        end
      end
    end

    def assign(run_limit_count: nil, report_limit_count: nil)
      self.run_limit_count = run_limit_count if run_limit_count
      self.report_limit_count = report_limit_count if report_limit_count
      self
    end

    def reached_run_limit?(new_value)
      if new_value
        run_count >= new_value
      else
        run_count >= run_limit_count
      end
    end

    def reached_report_limit?(new_value)
      if new_value
        report_count >= new_value
      else
        report_count >= report_limit_count
      end
    end

    def increment_run_count!
      self.run_count = run_count + 1
      save!
    end

    def increment_report_count!
      self.report_count = report_count + 1
      save!
    end

    def message
      process = key == caller ? 'Watching process' : "Process for '#{key}'"
      "#{process} is called for #{report_count}th. Report until for #{report_limit_count}th."
    end

    # For ActiveModel compatibility in Engine
    def to_param
      key
    end

    def update(attributes)
      attributes.each do |key, value|
        send("#{key}=", value)
      end
      save!
      true
    end

    def destroy!
      self.class.redis.del("#{BASE_KEY}.#{key}")
      true
    end

    private

    def save!
      raise 'key is empty!' unless @key

      self.updated_at = Time.current
      pp to_h
      self.class.redis.hset("#{BASE_KEY}.#{key}", to_h)
    end
  end
end
