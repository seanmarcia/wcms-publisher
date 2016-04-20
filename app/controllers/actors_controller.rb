class ActorsController < ApplicationController
  def create
    authorize @parent, :create_actor?

    # First find the actor's person record from the given person id
    if person_record_for_actor = Person.where(id: params[:_person_id]).first
      # Find the user record for that person, since it is the user we need to authenticate
      actor = User.where(person_id: person_record_for_actor.id).first
    end

    # Site permissions should let you set the role, page edition permissions is just edit
    ability = params[:role] || :edit

    # Not all people belong to a user. They need to log in before their user record gets created.
    if actor.nil?
      if person_record_for_actor.nil?
        flash[:error] = "Person was not found."
      else
        flash[:info] = "#{person_record_for_actor.name} needs to log into this site before he/she can be given access to this profile."
      end
    # @parent refers to the person we are adding the actor to
    elsif @parent.has_permission_to?(ability, actor)
      flash[:info] = "#{actor.name} already has the \"#{ability.to_s.titleize}\" role."
    elsif @parent.authorize!(actor, ability)
      flash[:info] = "#{actor.name}'s permissions have been successfully saved."
    else
      flash[:error] = "Something went wrong. Please try again."
    end
    redirect_to parent_edit_path(@parent, page: 'permissions')
  end

  def destroy
    authorize @parent, :destroy_actor?

    actor = User.find(params[:id])
    actor_roles = @parent.permissions.by_actor(actor).map{|perm| perm.ability}.to_sentence.humanize
    if @parent.unauthorize_all!(actor)
      flash[:info] = "#{actor.name}'s permissions have been successfully removed. <a href=/wcms_components/changes/#{@parent.history_tracks.last.id}/undo_destroy>Undo</a>"
    else
      flash[:error] = "Something went wrong. Please try again."
    end
    redirect_to parent_edit_path(@parent, page: 'permissions')
  end

end
