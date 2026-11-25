module Api
  module V1
    class MeController < BaseController
      before_action :authenticate_session!

      api :GET, "/api/v1/me", "Return the authenticated user's profile"
      formats [ "json" ]
      api_version "1"

      def show
        render json: {
          data: {
            user: {
              id: current_user.id,
              email: current_user.email,
              first_name: current_user.first_name,
              last_name: current_user.last_name,
              email_verified_at: current_user.email_verified_at
            }
          }
        }
      end
    end
  end
end
