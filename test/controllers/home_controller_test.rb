require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "should get inde" do
    get home_inde_url
    assert_response :success
  end
end
