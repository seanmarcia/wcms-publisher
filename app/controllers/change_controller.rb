class ChangeController < ApplicationController
  before_filter :set_change
  before_filter :pundit_authorize

  def undo
    set_parent

    if @change.undo!(modifier: current_user)
      if @change.action == 'create'
        flash[:info] = "Change was successfully reversed. "

    else
      flash[:error] = "Something went wrong. Please try again."
    end

    # ensure that the object wasn't just undone into nonexistence
    if @parent.class.where(id: @parent.id).present?
      redirect_to @parent
    else
      redirect_to @parent.class
    end
  end

  def undo_destroy
    if @change.undo!(modifier: current_user)
      flash[:info] = "#{@change.original[:title]} has been successfully recreated."
    else
      flash[:error] = "Something went wrong. Please try again."
    end
    redirect_to :back
  end

  private
  def set_change
    @change = Change.find(params[:id])
  end

  def pundit_authorize
    authorize (@change || Change)
  end
end
