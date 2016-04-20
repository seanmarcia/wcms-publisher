class RelationshipsController < ApplicationController
  before_action :set_flash

  def create
    if @relationship = Relationship.new_from_objects(base_object, related_object)
      authorize @relationship
      @relationship.modifier_id = current_user.id.to_s

      begin
        if @relationship.save
          @flash[:notice] = "Relationship was created."
        else
          @flash[:error] = @relationship.errors.full_messages.to_sentence
        end
      rescue Moped::Errors::OperationFailure => e
        logger.error(e)
        @flash[:error] = "Something went wrong. Most likely the relationship already exists."
      end
    else
      authorize Relationship
    end

    redirect_to :back, flash: @flash
  end

  def destroy
    if @relationship = Relationship.find(params[:id])
      authorize @relationship
      @relationship.modifier_id = current_user.id.to_s

      if @relationship.destroy
        @flash[:notice] = "Relationship was removed."
      else
        @flash[:warning] = "Could not remove relationship."
      end
    else
      authorize Relationship
    end

    redirect_to :back, flash: @flash
  end

  private

  def set_flash
    @flash = {} # since we are redirecting, we need to do flash messages a different way
  end

  def base_object
    @base_object ||= find_object(:base_type, :base_id)
  end

  def related_object
    @related_object ||= find_object(:related_type, :related_id)
  end

  def find_object(type_key, id_key)
    # let the attributes come at either the root level or nested under relationship
    type = params[type_key] || params[:relationship] && params[:relationship][type_key]
    id = params[id_key] || params[:relationship] && params[:relationship][id_key]

    begin
      type.to_s.constantize.find(id.to_s)
    rescue NameError
      # Not a valid type
      @flash[:error] = "Not a valid type."
      nil
    rescue NoMethodError
      # Type doesn't respond to find
      @flash[:error] = "Not a valid type."
      nil
    rescue Mongoid::Errors::DocumentNotFound
      # ID does not exist
      @flash[:error] = "Record with that ID does not exist."
      nil
    end
  end
end
