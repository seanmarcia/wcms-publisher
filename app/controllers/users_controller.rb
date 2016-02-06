class UsersController < ApplicationController
  before_filter :set_user, only: [:impersonate]
  before_filter :pundit_authorize

  def index
    @users = policy_scope(User).custom_search(params[:q]).asc(:first_name, :last_name).page(params[:page]).per(25)
  end

  def impersonate
    impersonate_user(@user)
    redirect_to root_path
  end

  def stop_impersonating
    stop_impersonating_user
    redirect_to users_path
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def pundit_authorize
    authorize (@user || User)
  end

end
