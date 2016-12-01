class FeaturesController < ApplicationController

  before_filter :set_feature, only: [:show, :edit, :update]
  before_filter :new_feature_from_params, only: [:new, :create]
  before_filter :set_feature_locations, only: [:new, :create, :edit, :update]
  before_filter :pundit_authorize

  def index
    @features = policy_scope(Feature)
    @available_feature_locations = FeatureLocation.in(id: @features.distinct(:feature_location_id)).asc(:title)

    @features = @features.custom_search(params[:q]) if params[:q]
    @features = @features.by_status(params[:status]) if params[:status]
    @features = @features.by_feature_location(params[:feature_location]) if params[:feature_location]
    @features = @features.desc(:publish_at).page(params[:page]).per(25)
  end

  def show
    redirect_to edit_feature_path @feature
  end

  def new
  end

  def create
    @feature.image = params[:image] if params[:image]
    @feature.mobile_image = params[:mobile_image] if params[:mobile_image]

    set_status

    if @feature.save
      if @feature.type == 'link'
        flash[:info] = "Feature was created. Please be sure to fill out the image elements."
      else
        flash[:info] = "Feature was created. Please be sure to fill out the image and #{@feature.type} elements."
      end
      redirect_to edit_feature_path @feature
    else
      render :new
    end
  end

  def update
    @feature.image = params[:image] if params[:image]
    @feature.mobile_image = params[:mobile_image] if params[:mobile_image]
    @feature.attributes = feature_params

    set_status
    if @feature.update feature_params
      flash[:info] = "Feature changes were saved."
      redirect_to edit_feature_path @feature, page: params[:page]
    else
      render :edit
    end
  end

  def sort
    params[:feature].each_with_index do |id, index|
      feature = Feature.find(id)
      authorize feature
      feature.update(order: index+1)
    end

    render nothing: true
  end

  protected

  def set_status
    return unless @feature.valid?
    return unless params[:transition].present?
    transition = params[:transition].to_s.downcase.gsub(/\s/, '_').to_sym
    return unless @feature.aasm.events.include?(transition)
    return unless policy(@feature).permitted_aasm_events.include?(transition)
    @feature.send(transition)
  end

  def set_feature_locations
    @feature_locations = {}
    fls=policy_scope(FeatureLocation)
    sites = fls.map(&:site).compact

    sites.each do |site|
      unless site.feature_locations.blank?
        @feature_locations[site.title] = site.feature_locations.map{|fl| [fl.title_with_dimensions, fl.id]}
      end
    end
  end

  def new_feature_from_params
    if params[:feature]
      @feature = Feature.new(feature_params)
    else
      @feature = Feature.new
    end
  end

  def feature_params
    if params[:feature]
      params.require(:feature).permit(*policy(@feature || Feature).permitted_attributes)
    else
      {}
    end
  end

  def set_feature
    @feature = Feature.find(params[:id])
  end

  def pundit_authorize
    authorize (@feature || Feature)
  end
end
