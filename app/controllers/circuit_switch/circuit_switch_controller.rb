require_dependency 'circuit_switch/application_controller'

module CircuitSwitch
  class CircuitSwitchController < ::CircuitSwitch::ApplicationController
    def index
      @circuit_switches = ::CircuitSwitch::CircuitSwitch.all.order(order_by)
    end

    def edit
      @circuit_switch = ::CircuitSwitch::CircuitSwitch.find(params[:id])
    end

    def update
      @circuit_switch = ::CircuitSwitch::CircuitSwitch.find(params[:id])
      if @circuit_switch.update circuit_switch_params
        flash[:success] = "Switch for `#{@circuit_switch.key}` is successfully updated."
        redirect_to circuit_switch_index_path
      else
        render :edit
      end
    end

    def destroy
      @circuit_switch = ::CircuitSwitch::CircuitSwitch.find(params[:id])
      @circuit_switch.destroy!
      flash[:success] = "Switch for `#{@circuit_switch.key}` is successfully destroyed."
      redirect_to circuit_switch_index_path
    end

    private

    def order_by
      params[:order_by].in?(%w[id due_date]) ? params[:order_by] : 'id'
    end

    def circuit_switch_params
      params.require(:circuit_switch).permit(:key, :caller, :run_count, :run_limit_count, :run_is_terminated, :report_count, :report_limit_count, :report_is_terminated, :due_date)
    end
  end
end
