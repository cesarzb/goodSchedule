module Api
    module V1
        class AuthenticationController < ApplicationController
            include ActionController::HttpAuthentication::Token
            class AuthenticationError < StandardError; end
            
            rescue_from ActionController::ParameterMissing, with: :param_missing
            rescue_from AuthenticationController::AuthenticationError, with: :authentication_error

            def create
                raise AuthenticationError unless !user.nil? && user.authenticate(params.require(:user).require(:password))
                token = AuthTokenService.encode(user.id)
                user.update(token_expiration: 14.days.from_now)

                render json: { token: token }, status: :ok
            end

            def destroy
                if current_user
                    token, _options = token_and_options(request)
                    current_user.update(token_expiration: Time.now)
                end
                render status: :no_content
            end

            private

            def param_missing(e)
                parameter_missing(e, :unauthorized)
            end

            def authentication_error
                render json: { errors: { 'Username or password': [ 'is incorrect' ] } }, status: :unauthorized
            end

            def user
                @user ||= User.find_by(username: params.require(:user).require(:username))
            end
        end
    end
end