module Api
    module V1
        class AuthenticationController < ApplicationController
            rescue_from ActionController::ParameterMissing, with: :parameter_missing

            def create
                params.require(:username)
                params.require(:password)

                token = AuthTokenService.encode
                render json: { token: token }, status: :ok
            end

            private

            def parameter_missing(e)
                render json: { error: e }, status: :unauthorized
            end
        end
    end
end