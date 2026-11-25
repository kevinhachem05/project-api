require "test_helper"

module Api
  module V1
    class SessionsControllerTest < ActionDispatch::IntegrationTest
      test "requests a signin verification for an existing verified user" do
        user = User.create!(email: "verified@example.com", first_name: "Verified", last_name: "User",
                            email_verified_at: Time.current)

        post api_v1_sessions_url,
             params: { session: { email: user.email, client_type: "mobile" } },
             as: :json

        assert_response :accepted
        verification_id = response.parsed_body.dig("data", "verification_id")
        verification = EmailVerification.find_by!(public_id: verification_id)

        assert verification.sign_in?
        assert verification.matches_code?("000000")
      end

      test "returns the same accepted response for an unknown account" do
        assert_no_difference("EmailVerification.count") do
          post api_v1_sessions_url,
               params: { session: { email: "missing@example.com", client_type: "browser" } },
               as: :json
        end

        assert_response :accepted
        assert response.parsed_body.dig("data", "verification_id").present?
      end

      test "returns and revokes the authenticated session" do
        user = User.create!(email: "session@example.com", first_name: "Session", last_name: "User",
                            email_verified_at: Time.current)
        session, token = Session.issue_for!(user:, client_type: :mobile, ip_address: "127.0.0.1")

        get api_v1_session_url(session.id), headers: bearer_headers(token)
        assert_response :success
        assert_equal session.id, response.parsed_body.dig("data", "id")

        delete api_v1_session_url(session.id), headers: bearer_headers(token)
        assert_response :no_content
        assert session.reload.revoked?
      end

      private

      def bearer_headers(token)
        { "Authorization" => "Bearer #{token}" }
      end
    end
  end
end
