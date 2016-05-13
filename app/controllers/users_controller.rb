class UsersController < ApplicationController

  def index
    authorize(User)
    @users = policy_scope(User).custom_search(params[:q]).asc(:first_name, :last_name).page(params[:page]).per(25)
  end

  def impersonate
    @user = User.find(params[:id])
    authorize(@user)
    impersonate_user(@user)
    redirect_to root_path
  end

  def stop_impersonating
    authroize(User)
    stop_impersonating_user
    redirect_to users_path
  end

end
