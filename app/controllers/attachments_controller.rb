class AttachmentsController < ApplicationController
  include ActivityLoggable

  before_filter :pundit_authorize
  before_filter :set_parent
  before_filter :new_attachment_from_params, only: [:new, :create]
  before_filter :set_attachment, only: :destroy

  def create
    # Bypassing strong parameters because metadata can be anything
    @parent_class = set_attachable_type(@attachment.attachable_type)
    if @parent_class
      @attachment.metadata = params[:attachment][:metadata]
      if @attachment.save
        binding.pry
        log_activity(@attachment.previous_changes, parent: @parent_class.find(@attachment.attachable_id))
        flash[:info] = "Attachment was created."
        redirect_to :back
      else
        render :new
      end
    else
      flash[:error] = "This is not the attachable type you were looking for."
      redirect_to :back
    end
  end

  def new
    if params[:attachable_type] && params[:attachable_id]
      log_activity(@attachment.previous_changes, parent: @attachment)
      if (attachable = set_attachable_type(params[:attachable_type]))
        @attachment = attachable.find(params[:attachable_id]).attachments.new
      end
    end
  end

  def destroy
    @attachment.destroy

    redirect_to :back
  end

  private

  def set_parent
    if params[:page_edition_id].present?
      @parent = PageEdition.find(params[:page_edition_id])
    end
  end

  def set_attachment
    @attachment = Attachment.find(params[:id])
  end

  def new_attachment_from_params
    if params[:attachment]
      @attachment = Attachment.new(attachment_params)
    else
      @attachment = Attachment.new
    end
  end

  def attachment_params
    params.require(:attachment).permit(*policy(@attachment || Attachment).permitted_attributes)
  end

  def set_attachable_type(type)
    case type
    when 'PageEdition' then PageEdition
    else false
    end
  end

  def pundit_authorize
    authorize (@attachment || Attachment)
  end
end
