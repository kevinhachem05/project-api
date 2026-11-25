require "test_helper"

module Api
  module V1
    class EmailVerificationsControllerTest < ActionDispatch::IntegrationTest
      test "verifies a signup code and creates a session" do
        user = User.create!(email: "new@example.com", first_name: "New", last_name: "User")
        verification = EmailVerifications::Issue.call(user:, purpose: :sign_up, client_type: :browser)

        patch api_v1_email_verification_url(verification.public_id),
              params: { email_verification: { code: "000000" } },
              as: :json

        assert_response :created
        response_data = response.parsed_body.fetch("data")
        assert_equal user.id, response_data.dig("user", "id")
        assert response_data.dig("user", "email_verified_at").present?
        assert response_data.dig("session", "token").present?
      end

      test "rejects an incorrect code" do
        user = User.create!(email: "incorrect@example.com", first_name: "Incorrect", last_name: "Code")
        verification = EmailVerifications::Issue.call(user:, purpose: :sign_up, client_type: :browser)

        patch api_v1_email_verification_url(verification.public_id),
              params: { email_verification: { code: "123456" } },
              as: :json

        assert_response :unprocessable_entity
        assert_equal "invalid_verification_code", response.parsed_body.dig("error", "code")
      end

      test "verifies a signin code for an already verified user" do
        user = User.create!(email: "verified@example.com", first_name: "Verified", last_name: "User",
                            email_verified_at: Time.current)
        verification = EmailVerifications::Issue.call(user:, purpose: :sign_in, client_type: :mobile)

        patch api_v1_email_verification_url(verification.public_id),
              params: { email_verification: { code: "000000" } },
              as: :json

        assert_response :created
        assert_equal "mobile", response.parsed_body.dig("data", "session", "client_type")
      end
    end
  end
end
