module SessionsHelper
  #渡されたユーザーでログイン
  def log_in(user)
    session[:user_id] = user.id
  end
  
  #現在ログイン中のユーザーを返す（いる場合）
  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end
  
  #ログインユーザーがいる→true いない→false
  def logged_in?
    !current_user.nil?
  end
  
  def log_out
    session.delete(:user_id)
    @current__user = nil
  end
end