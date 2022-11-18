class Api::V1::UsersController < ApplicationController
  before_action :authenticate_user, except: %i[ create ]
  before_action :authorize_user, only: %i[ show ]

  rescue_from ActionController::ParameterMissing, with: :param_missing

  def create
    user = User.new(user_params)

    if user.save
      token = AuthTokenService.encode(user.id)
      user.update(token_expiration: 14.days.from_now)

      render json: { token: token }, status: :created
    else
      render json: { errors: user.errors }, status: :unprocessable_entity
    end
  end

  def change_password
    current_user.password = params.require(:password)
    current_user.password_confirmation = params.require(:password_confirmation)
    if current_user.save
      @current_user.reload
      render status: :ok
    else
      render json: { errors: e }, status: :unprocessable_entity
    end
  end

  def show
    render json: UserRepresenter.new(User.find(params[:id])).as_json, status: :ok
  end
  
  def settings_show
    render json: JSON.parse(current_user.settings), status: :ok
  rescue JSON::ParserError, TypeError
    render json: {errors: { "Settings": [ "weren't initialized yet, or they're not in JSON format" ] } }, status: :unprocessable_entity
  end

  def settings_edit
    # binding.irb
    current_user.update_attribute(:settings, { "settings": params[:settings] }.to_json)
    # binding.irb
    render status: :ok
  end

  # index and destroy actions are for admin users
  # that are yet to be added
  def index
  end

  def destroy
  end

  private

  def authorize_user
    user = User.find(params[:id])
    render status: :unauthorized unless current_user == user # admin role condition to be added in the future
  rescue ActiveRecord::RecordNotFound
    # admin role condition to be added, to tell admin, that there is no such user
    render status: :unauthorized
  end

  def param_missing(e)
    parameter_missing(e, :unprocessable_entity)
  end
  
  def user_params
    params.require(:user).permit( :username, :password, :password_confirmation )
  end
end
