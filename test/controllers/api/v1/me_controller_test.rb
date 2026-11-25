require "test_helper"

module Api
  module V1
    class MeControllerTest < ActionDispatch::IntegrationTest
      test "returns the authenticated user's safe profile fields" do
        user = User.create!(email: "me@example.com", first_name: "Current", last_name: "User",
                            email_verified_at: Time.current)
        _session, token = Session.issue_for!(user:, client_type: :mobile, ip_address: "127.0.0.1")

        get api_v1_me_url, headers: bearer_headers(token)

        assert_response :success
        profile = response.parsed_body.dig("data", "user")
        assert_equal user.id, profile.fetch("id")
        assert_equal user.email, profile.fetch("email")
        assert_equal user.first_name, profile.fetch("first_name")
        assert_equal user.last_name, profile.fetch("last_name")
        assert_not profile.key?("encrypted_password")
        assert_not profile.key?("platform_admin")
      end

      test "rejects requests without a valid session" do
        get api_v1_me_url

        assert_response :unauthorized
        assert_equal "unauthorized", response.parsed_body.dig("error", "code")
      end

      private

      def bearer_headers(token)
        { "Authorization" => "Bearer #{token}" }
      end
    end
  end
end
