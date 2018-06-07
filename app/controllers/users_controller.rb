class UsersController < ApplicationController
  before_action :owner, only: :show
  before_action :check_transactions, only: :show

  def index
    @users = User.all
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.create_with_eth
      session[:user_id] = @user.id
      redirect_to user_path(@user)
    else
      render :new
    end
  end

  def show; end

  private
  def user_params
    params.require(:user).permit(:name, :password)
  end

	def owner
    @user = User.find(params[:id])
		redirect_to root_path, notice: 'Access denied' unless @user == current_user
	end

  def check_transactions
    @user.sync_transactions
  end
end
