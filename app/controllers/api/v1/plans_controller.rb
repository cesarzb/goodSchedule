class Api::V1::PlansController < ApplicationController
  before_action :set_plan, only: %i[ show update destroy ]
  before_action :authenticate_user

  # GET /api/v1/plans
  def index
    @plans = Plan.all

    render json: @plans
  end

  # GET /api/v1/plans/1
  def show
    render json: @plan
  end

  # POST /api/v1/plans
  def create
    @plan = Plan.new(plan_params)

    if @plan.save
      render json: @plan, status: :created
    else
      render json: { errors: @plan.errors }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/plans/1
  def update
    if @plan.update(plan_params)
      render json: @plan
    else
      render json: { errors: @plan.errors }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/plans/1
  def destroy
    @plan.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_plan
      @plan = Plan.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def plan_params
      params.require(:plan).permit(:name, :user_id)
    end
end
