class UsersController < ApplicationController
  before_action :logged_in_user, only: [:edit, :update, :destroy]
  before_action :load_user, only: [:show, :edit, :update]
  before_action :correct_user, only: [:edit, :update]

  def index
    if params[:search]
      @users = User.search(params[:search])
        .paginate page: params[:page], per_page: 10
    else
      @users = User.paginate page: params[:page], per_page: 10
    end
    @tmp_top =(User.joins('LEFT OUTER JOIN user_logs ON user_logs.user_id = users.id')).select('users.*, SUM(number_of_word) AS total_word ').group('users.id').order('total_word DESC').limit 10
    @top_ranges=(@tmp_top)
        .paginate page: params[:page], per_page: 10
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new user_params
    if @user.save
      log_in @user
      flash[:success] = t "controllers.users.create.flash_success",
        name: @user.name
      redirect_to @user
    else
      render :new
    end
  end

  def show
    redirect_to root_path if @user.nil?
  end

  def edit
  end

  def update
    if @user.update_attributes user_params
      flash[:success] = t "controllers.users.update.flash_success"
      redirect_to @user
    else
      render :edit
    end
  end

  private
  def user_params
    params.require(:user).permit :name, :email, :password, :password_confirmation, :avatar
  end

  def correct_user
    redirect_to root_url unless current_user? @user
  end

  def load_user
    @user = User.find params[:id] if User.exists? params[:id]
  end
end
