module Api
  module V1
    class SessionsController < BaseController
      before_action :authenticate_session!, only: %i[show destroy]

      api :POST, "/api/v1/sessions", "Request a sign-in verification code"
      param :session, Hash, required: true do
        param :email, String, required: true
        param :client_type, String, required: true, desc: "browser or mobile"
      end
      formats [ "json" ]
      api_version "1"

      def create
        attributes = params.require(:session).permit(:email, :client_type)
        unless Session.client_types.key?(attributes[:client_type].to_s)
          return render_error("invalid_client_type", "client_type must be browser or mobile.", :unprocessable_entity)
        end

        verification = Sessions::RequestSignIn.call(**attributes.to_h.symbolize_keys)

        render json: {
          data: {
            verification_id: verification&.public_id || SecureRandom.uuid,
            expires_at: verification&.expires_at || EmailVerification::CODE_LIFETIME.from_now,
            message: "If the account can sign in, a verification code has been sent."
          }
        }, status: :accepted
      end

      api :GET, "/api/v1/sessions/:id", "Return the current session"
      param :id, String, required: true
      formats [ "json" ]
      api_version "1"

      def show
        return render_error("not_found", "Session not found.", :not_found) unless current_session.id.to_s == params[:id]

        render json: { data: session_payload(current_session) }
      end

      api :DELETE, "/api/v1/sessions/:id", "Revoke the current session"
      param :id, String, required: true
      formats [ "json" ]
      api_version "1"

      def destroy
        return render_error("not_found", "Session not found.", :not_found) unless current_session.id.to_s == params[:id]

        current_session.update!(revoked_at: Time.current)
        head :no_content
      end

      private

      def session_payload(session)
        { id: session.id, client_type: session.client_type, expires_at: session.expires_at,
          absolute_expires_at: session.absolute_expires_at, last_active_at: session.last_active_at }
      end
    end
  end
end
