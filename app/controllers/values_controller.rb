class ValuesController < ApplicationController

    def index
        @values = Value.all(params[:metric_id])
    end

    def edit
        @value = Value.find(params[:id], params[:metric_id])
        @value.value || 0
    end

    def new
        @value = Value.new
        @value.value = 0
    end

    def create
        user = User.find(params[:user_id])
        @value = Value.new(owner: params[:user_id], value: params[:value].to_i, metric: params[:metric_id])

        if @value.save
            redirect_to metric_values_path(metric_id: params[:metric_id])
        else
            render :new
        end
    end

    def update
        @value = Value.find(params[:id], params[:metric_id])
        @value.value = params[:value].to_i
        if @value.save
            redirect_to metric_values_path(metric_id: params[:metric_id])
        else
            render :edit
        end
    end
end
