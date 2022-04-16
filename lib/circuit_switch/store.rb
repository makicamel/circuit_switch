require 'redis'

module CircuitSwitch
  class Store
    BASE_KEY = 'circuit_switch'.freeze
    attr_accessor :key, :caller, :run_count, :run_limit_count, :run_is_terminated, :report_count, :report_limit_count, :report_is_terminated, :due_date
    def initialize(key: nil, caller: nil, run_count: 0, run_limit_count: 10, run_is_terminated: false, report_count: 0, report_limit_count: 10, report_is_terminated: false, due_date: nil)
      @key = key || caller
      @caller = caller
      @run_count = run_count
      @run_limit_count = run_limit_count
      @run_is_terminated = run_is_terminated
      @report_count = report_count
      @report_limit_count = report_limit_count
      @report_is_terminated = report_is_terminated
      @due_date = due_date
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
        due_date: due_date
      }
    end

    class << self
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

      def redis
        @redis ||= Redis.new
      end

      private

      def convert_hash_from_redis(hash)
        hash.to_h do |k, v|
          key = k.to_sym
          value = case key
          when /_count$/, /_terminated$/
            v.to_i
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

    private

    def save!
      raise 'key is empty!' unless @key

      self.class.redis.hset("#{BASE_KEY}.#{key}", to_h)
    end
  end
end
