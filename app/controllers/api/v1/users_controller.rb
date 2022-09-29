class Api::V1::UsersController < ApplicationController
  before_action :authenticate_user, only: %i[ index destroy show ]
  
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

  def user_params
    params.require(:user).permit( :username, :password, :password_confirmation )
  end
end
