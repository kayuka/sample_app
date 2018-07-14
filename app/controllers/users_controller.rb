class UsersController < ApplicationController
  before_action :logged_in_user, only: [:edit, :update, :index, :destroy]
  before_action :correct_user,   only: [:edit, :update]
  before_action :admin_user,     only: :destroy
  
  def new
    @user = User.new
  end

  def show
    @user = User.find(params[:id])
    redirect_to root_url and return unless @users.nil?
  end
  
  def create
    @user = User.new(user_params)
    if @user.save
      @user.send_activation_email
      flash[:info] = "Please check your email to activate your account."
      redirect_to root_url
    else
      render 'new'
    end
  end
  
  def edit
    @user = User.find(params[:id])
  end
  
  def update
    @user = User.find(params[:id])
      if @user.update_attributes(user_params)
        flash[:success] = "Profile updated"
        redirect_to @user
      else
        render 'edit'
      end
  end
  
  def index
    @users = User.where(activated: true).paginate(page: params[:page])
  end
  
  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted"
    redirect_to users_url
  end
  
  #以降のメソッドはUsersControllerクラス内からしか呼び出せない
  private

    def user_params #user_params = params[:user] の脆弱性防止版(admin属性は許可されない)
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end
  
    
    def logged_in_user
      unless logged_in? then
        store_location
        flash[:danger] = "Please log in."
        redirect_to login_url
      end
    end
  
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user)
    end
  
    def admin_user
    redirect_to(root_url) unless current_user.admin?
    end
end