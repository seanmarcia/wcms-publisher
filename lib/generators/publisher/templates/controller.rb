class <%= plural_table_name.camelize %>Controller < ApplicationController
  include SetModifier

  before_filter :set_<%= singular_table_name %>, only: [:show, :edit, :update]
  before_filter :new_<%= singular_table_name %>_from_params, only: [:new, :create]
  before_filter :pundit_authorize

  def index
    @<%= plural_table_name %> = policy_scope(<%= class_name %>)
    @<%= plural_table_name %> = @<%= plural_table_name %>.custom_search(params[:q]) if params[:q]
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
    permitted_params(:<%= singular_table_name %>) do |p|
      <%- Array(attributes).each do |attr| -%><%- if attr.type == :array -%>
      p[:<%= attr.name.to_sym %>] = p[:<%= attr.name.to_sym %>].split(',').map(&:strip) if p[:<%= attr.name.to_sym %>]
      <%- end -%><%- end -%>
    end
  end

  def set_<%= singular_table_name %>
    @<%= singular_table_name %> = <%= class_name %>.find(params[:id]) if params[:id]
    @page_name = @<%= singular_table_name %>.try(:title)
  end

  def pundit_authorize
    authorize (@<%= singular_table_name %> || <%= class_name %>)
  end
end
