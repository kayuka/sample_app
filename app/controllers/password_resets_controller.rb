class PasswordResetsController < ApplicationController
  before_action :get_user, only:[:edit, :update]
  before_action :valid_user, only:[:edit, :update]
  before_action :check_expiration, only:[:edit, :update]
  
  def new
  end

  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = "Email sent with password reset instructions"
      redirect_to root_url
    else
      #次のリクエストが発生するまで表示
      flash.now[:danger] = "Email address not found"
      render 'new'
    end
  end

  def edit
  end
  
  def update
    #新しいパスワードが空になっていないか
    if params[:user][:password].empty?
      @user.errors.add(:password, :blank)
      render 'password_resets/edit'
    #正しいパスワードが入力された場合
    elsif @user.update_attributes(user_params)
      log_in @user
      #password再設定後、盗みとられるのを防ぐため
      @user.update_attribute(:reset_digest, nil)
      flash[:success] = "Password has been reset."
      redirect_to @user
    #パスワードが入力されたが無効な値の場合
    else
      render 'password_resets/edit'
    end
    
  end

  private
    def user_params
      params.require(:user).permit(:password, :password_confirmation)
    end
    
    def get_user
      @user = User.find_by(email: params[:email])
    end
    
    def valid_user
      unless(@user && @user.activated? && @user.authenticated?(:reset, params[:id]))
      redirect_to root_url
      end
    end
    
    def check_expiration
      if @user.password_reset_expired?
        flash[:danger] = "Password reset has expired."
        redirect_to new_password_reset_url
      end
    end
    
end
