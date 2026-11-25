module Api
  module V1
    class BaseController < ApplicationController
      attr_reader :current_user, :current_session

      rescue_from ActiveRecord::RecordInvalid, with: :render_invalid_record
      rescue_from ActionController::ParameterMissing, with: :render_parameter_missing
      rescue_from EmailVerifications::Issue::DeliveryFailed, with: :render_delivery_failed

      private

      def authenticate_session!
        raw_token = request.authorization.to_s.match(/\ABearer\s+(\S+)\z/i)&.captures&.first
        session = Session.includes(:user).find_by(token_digest: Digest::SHA256.hexdigest(raw_token)) if raw_token

        unless session && session.revoked_at.nil? && !session.expired? && session.user.active? && session.user.email_verified_at.present?
          return render_error("unauthorized", "A valid session is required.", :unauthorized)
        end

        @current_session = session
        @current_user = session.user

        if session.browser? && request_unsafe? && !valid_csrf_token?
          return render_error("invalid_csrf_token", "A valid X-CSRF-Token header is required.", :forbidden)
        end

        session.refresh_activity!
      end

      def request_unsafe?
        !request.get? && !request.head? && !request.options?
      end

      def valid_csrf_token?
        submitted_token = request.headers["X-CSRF-Token"].to_s
        ActiveSupport::SecurityUtils.secure_compare(current_session.csrf_token, submitted_token)
      end

      def render_error(code, message, status, details: nil)
        render json: { error: { code:, message:, details: } }.compact, status:
      end

      def render_invalid_record(error)
        render_error("validation_failed", "The request could not be completed.", :unprocessable_entity,
                     details: error.record.errors.to_hash)
      end

      def render_parameter_missing(error)
        render_error("parameter_missing", "Required parameter is missing: #{error.param}.", :bad_request)
      end

      def render_delivery_failed
        render_error("email_delivery_failed", "The verification email could not be sent.", :service_unavailable)
      end
    end
  end
end
