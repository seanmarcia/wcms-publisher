class <%= plural_table_name.camelize %>Controller < ApplicationController

  before_filter :set_<%= singular_table_name %>, only: [:show, :edit, :update]
  before_filter :new_<%= singular_table_name %>_from_params, only: [:new, :create]
  before_filter :pundit_authorize

  def index
    @<%= plural_table_name %> = policy_scope(<%= class_name %>)
    @<%= plural_table_name %> = @<%= plural_table_name %>.desc(:title).page(params[:page]).per(25)
  end

  def show
    redirect_to [:edit, @<%= singular_table_name %>]
  end

  def new
  end

  def create
    if @<%= singular_table_name %>.save
      redirect_to [:edit, @<%= singular_table_name %>]
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @<%= singular_table_name %>.update_attributes(<%= singular_table_name %>_params)
      redirect_to [:edit, @<%= singular_table_name %>]
    else
      render :edit
    end
  end

  private

  def new_<%= singular_table_name %>_from_params
    if params[:<%= singular_table_name %>]
      @<%= singular_table_name %> = <%= class_name %>.new(<%= singular_table_name %>_params)
    else
      @<%= singular_table_name %> = <%= class_name %>.new
    end
  end

  def <%= singular_table_name %>_params
    <%- Array(attributes).each do |attr| -%><%- if attr.type == :array -%>
    params[:<%= singular_table_name %>][:<%= attr.name.to_sym %>] = params[:<%= singular_table_name %>][:<%= attr.name.to_sym %>].split(',')
    <%- end -%><%- end -%>
    <%- if options[:presentation_data] -%>
    params.require(:<%= singular_table_name %>).permit(*policy(@<%= singular_table_name %> || <%= class_name %>).permitted_attributes).tap do |whitelisted|
      # You have to whitelist the hash this way, see https://github.com/rails/rails/issues/9454
      whitelisted[:presentation_data] = params[:pdata] if params[:pdata].present?
    end
    <%- else -%>
    params.require(:<%= singular_table_name %>).permit(*policy(@<%= singular_table_name %> || <%= class_name %>).permitted_attributes)
    <%- end -%>
  end

  def set_<%= singular_table_name %>
    @<%= singular_table_name %> = <%= class_name %>.find(params[:id]) if params[:id]
    @page_name = @<%= singular_table_name %>.try(:title)
  end

  def pundit_authorize
    authorize (@<%= singular_table_name %> || <%= class_name %>)
  end

end
