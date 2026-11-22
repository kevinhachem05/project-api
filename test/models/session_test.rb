require "test_helper"

class SessionTest < ActiveSupport::TestCase
  test "supports browser and mobile clients" do
    assert_equal %w[mobile browser], Session.client_types.keys
  end

  test "belongs to a user" do
    assert_equal :belongs_to, Session.reflect_on_association(:user).macro
  end
end
