require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "only active platform administrators can authenticate" do
    admin = User.new(platform_admin: true, status: :active)
    regular_user = User.new(platform_admin: false, status: :active)
    suspended_admin = User.new(platform_admin: true, status: :suspended)

    assert admin.active_for_authentication?
    refute regular_user.active_for_authentication?
    refute suspended_admin.active_for_authentication?
  end

  test "has the expected account statuses" do
    assert_equal %w[active suspended deactivated], User.statuses.keys
  end
end
