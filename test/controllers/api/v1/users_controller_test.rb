require "test_helper"

module Api
  module V1
    class UsersControllerTest < ActionDispatch::IntegrationTest
      test "creates a user and a signup verification" do
        assert_difference("User.count", 1) do
          post api_v1_users_url, params: {
            user: { email: "new@example.com", first_name: "New", last_name: "User" },
            client_type: "browser"
          }, as: :json
        end

        assert_response :created
        response_data = response.parsed_body.fetch("data")
        verification_id = response_data.dig("email_verification", "id")
        verification = EmailVerification.find_by!(public_id: verification_id)

        assert_equal "new@example.com", response_data.dig("user", "email")
        assert verification.sign_up?
        assert verification.matches_code?("000000")
      end

      test "returns validation errors for invalid signup attributes" do
        assert_no_difference("User.count") do
          post api_v1_users_url, params: {
            user: { email: "invalid", first_name: "", last_name: "User" }
          }, as: :json
        end

        assert_response :unprocessable_entity
        assert_equal "validation_failed", response.parsed_body.dig("error", "code")
      end
    end
  end
end
