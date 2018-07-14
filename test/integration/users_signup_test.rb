require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  
  def setup
    #送信メールをためる配列をテスト前にクリア
   ActionMailer::Base.deliveries.clear
  end
  
  test "invalid signup information" do
    get signup_path
    assert_no_difference 'User.count' do
      #assert_no_differenceを実行する前後でユーザー数が変わらないことをテストする
      post signup_path, params: { user:{ name: "",
        email: 'user@invalid', password: 'foo', password_confirmation: 'bar'
      }}
    end
    assert_template 'users/new'
    #_error_messages.html.erbまで読み込めているか？
    assert_select 'div#error_explanation'
    #form_forがエラー時に勝手に出力するclass
    assert_select 'div.field_with_errors'
  end
  
#ユーザー登録の終わったユーザーがログイン状態になっているかを確認
  test "valid signup information with account activation" do
    get signup_path
    assert_difference('User.count', 1) do
      post users_path, params:{ user: 
                        { name: "Example User",
                          email: "user@example.com",
                          password: "password",
                          password_confirmation: "password" } }
    end
    assert_equal 1, ActionMailer::Base.deliveries.size
    #直前に作られたインスタンス変数を取得
    user = assigns(:user)
    assert_not user.activated?
    #有効化されていない状態でログイン
    log_in_as(user)
    assert_not is_logged_in?
    #有効化トークンが不正な場合
    get edit_account_activation_path("invalid token", email: user.email)
    assert_not is_logged_in?
    #トークンは正しいが、メールアドレスが無効な場合
    get edit_account_activation_path(user.activation_token, email: 'wrong_address')
    assert_not is_logged_in?
    #有効化トークンが正しい場合
    get edit_account_activation_path(user.activation_token, email: user.email)
    assert user.reload.activated?
    #リダイレクト先まで確認
    follow_redirect!
    assert_template 'users/show'
    assert_not flash.nil?
    assert is_logged_in?
  end
end
