require "test_helper"

class QuizControllerTest < ActionDispatch::IntegrationTest
  test "should get start" do
    get quiz_start_url
    assert_response :success
  end

  test "should get show" do
    get quiz_show_url
    assert_response :success
  end

  test "should get evaluate_answer" do
    get quiz_evaluate_answer_url
    assert_response :success
  end

  test "should get result" do
    get quiz_result_url
    assert_response :success
  end
end
