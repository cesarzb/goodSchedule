module Api
    module V1
        class AuthenticationController < ApplicationController
            rescue_from ActionController::ParameterMissing, with: :parameter_missing

            def create
                if user.authenticate(params.require(:password))
                    token = AuthTokenService.encode(user.id)
                    render json: { token: token }, status: :ok
                else
                    render json: { error: 'Username or password is incorrect' }, status: :unauthorized
                end
            end

            private

            def user
                username = params.require(:username)
                user = User.find_by(username: username)
            end

            def parameter_missing(e)
                render json: { error: e }, status: :unauthorized
            end
        end
    end
end