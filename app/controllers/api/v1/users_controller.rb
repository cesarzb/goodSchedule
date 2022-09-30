class Api::V1::UsersController < ApplicationController
  before_action :authenticate_user, only: %i[ index destroy show change_password ]
  
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

  #def show
  #  render json: { user: { username: current_user.username, created_at: current_user.created_at, last_login:  } }
  #end
  
  # index and destroy actions are for admin users
  # that are yet to be added
  def index
  end

  def destroy
  end

  private

  def param_missing(e)
    parameter_missing(e, :unprocessable_entity)
  end
  
  def user_params
    params.require(:user).permit( :username, :password, :password_confirmation )
  end
end
