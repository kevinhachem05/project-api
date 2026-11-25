module Api
  module V1
    class UsersController < BaseController
      api :POST, "/api/v1/users", "Register a user and send an email verification code"
      param :user, Hash, required: true do
        param :email, String, required: true
        param :first_name, String, required: true
        param :last_name, String, required: true
      end
      param :client_type, String, required: false, desc: "browser or mobile; defaults to browser"
      formats [ "json" ]
      api_version "1"

      def create
        attributes = params.require(:user).permit(:email, :first_name, :last_name)
        client_type = params[:client_type].presence || "browser"
        return render_error("invalid_client_type", "client_type must be browser or mobile.", :unprocessable_entity) unless Session.client_types.key?(client_type)

        user, verification = Users::Register.call(attributes:, client_type:)

        render json: {
          data: {
            user: user_payload(user),
            email_verification: verification_payload(verification)
          }
        }, status: :created
      end

      private

      def user_payload(user)
        { id: user.id, email: user.email, first_name: user.first_name, last_name: user.last_name,
          email_verified_at: user.email_verified_at, status: user.status }
      end

      def verification_payload(verification)
        { id: verification.public_id, expires_at: verification.expires_at }
      end
    end
  end
end
