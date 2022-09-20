module Api
    module V1
        class AuthenticationController < ApplicationController
            include ActionController::HttpAuthentication::Token
            class AuthenticationError < StandardError; end
            before_action :authenticate_user, only: :destroy
            
            rescue_from ActionController::ParameterMissing, with: :parameter_missing
            rescue_from AuthenticationController::AuthenticationError, with: :authentication_error

            def create
                raise AuthenticationError unless !user.nil? && user.authenticate(params.require(:password))
                token = AuthTokenService.encode(user.id)
                user.update(token_expiration: 14.days.from_now)

                render json: { token: token }, status: :ok
            end

            def destroy
                token, _options = token_and_options(request)
                current_user = User.find(AuthTokenService.decode(token))
                current_user.update(token_expiration: Time.now)

                render status: :no_content
            end

            private

            def authentication_error
                render json: { error: 'Username or password is incorrect' }, status: :unauthorized
            end

            def user
                @user ||= User.find_by(username: params.require(:username))
            end

            def parameter_missing(e)
                render json: { error: e }, status: :unauthorized
            end
        end
    end
end