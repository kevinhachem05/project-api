module Api
  module V1
    class EmailVerificationsController < BaseController
      api :POST, "/api/v1/email_verifications", "Send or resend a six-digit email verification code"
      param :email, String, required: true
      param :purpose, String, required: true, desc: "sign_up or sign_in"
      param :client_type, String, required: false, desc: "browser or mobile; defaults to browser"
      formats [ "json" ]
      api_version "1"

      def create
        attributes = params.permit(:email, :purpose, :client_type)
        unless EmailVerification.purposes.key?(attributes[:purpose].to_s)
          return render_error("invalid_purpose", "purpose must be sign_up or sign_in.", :unprocessable_entity)
        end
        client_type = attributes[:client_type].presence || "browser"
        unless Session.client_types.key?(client_type)
          return render_error("invalid_client_type", "client_type must be browser or mobile.", :unprocessable_entity)
        end

        attributes[:client_type] = client_type
        verification = find_and_issue_verification(**attributes.to_h.symbolize_keys)

        render json: {
          data: {
            verification_id: verification&.public_id || SecureRandom.uuid,
            expires_at: verification&.expires_at || EmailVerification::CODE_LIFETIME.from_now,
            message: "If the account can be verified, a code has been sent."
          }
        }, status: :accepted
      end

      api :PATCH, "/api/v1/email_verifications/:id", "Confirm a code and create a session"
      param :id, String, required: true, desc: "Opaque verification ID returned by the create endpoint"
      param :email_verification, Hash, required: true do
        param :code, String, required: true, desc: "Six-digit code"
      end
      formats [ "json" ]
      api_version "1"

      def update
        code = params.require(:email_verification).permit(:code).fetch(:code)
        user, session, raw_token = EmailVerifications::Verify.call(
          public_id: params[:id],
          code:,
          ip_address: request.remote_ip
        )

        render json: {
          data: {
            user: { id: user.id, email: user.email, first_name: user.first_name,
                    last_name: user.last_name, email_verified_at: user.email_verified_at },
            session: {
              id: session.id,
              token: raw_token,
              csrf_token: session.csrf_token,
              client_type: session.client_type,
              expires_at: session.expires_at,
              absolute_expires_at: session.absolute_expires_at
            }
          }
        }, status: :created
      rescue EmailVerifications::Verify::InvalidCode
        render_error("invalid_verification_code", "The verification code is invalid or expired.", :unprocessable_entity)
      end

      private

      def find_and_issue_verification(email:, purpose:, client_type: "browser")
        normalized_email = email.to_s.strip.downcase
        user = User.where("LOWER(email) = ?", normalized_email).first

        eligible = case purpose.to_s
        when "sign_up" then user && user.email_verified_at.nil?
        when "sign_in" then user && user.active? && user.email_verified_at.present?
        end
        return unless eligible

        EmailVerifications::Issue.call(user:, purpose:, client_type:)
      end
    end
  end
end
