class ActorsController < ApplicationController
  include ActivityLoggable

  before_filter :pundit_authorize

  def create
    # First find the actor's person record from the given person id
    person_record_for_actor = Person.find(params[:_person_id])

    # Find the user record for that person, since it is the user we need to authenticate
    actor = User.where(person_id: person_record_for_actor.id).first

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
      log_activity({"added"=>[nil, actor.id]}, parent: @parent, user: current_user, activity: 'create', child: 'actor')
      flash[:info] = "#{actor.name}'s permissions have been successfully saved."
    else
      flash[:error] = "Something went wrong. Please try again."
    end
    redirect_to parent_edit_path(@parent, page: 'permissions')
  end

  def destroy
    actor = User.find(params[:id])
    actor_roles = @parent.permissions.by_actor(actor).map{|perm| perm.ability}.to_sentence.humanize
    if @parent.unauthorize_all! actor
      log_activity({"removed"=>[actor.id, nil]}, parent: @parent, user: current_user, activity: 'destroy', child: 'actor', message: "Removed #{actor.to_s} as an #{actor_roles}.")
      flash[:info] = "#{actor.name}'s permissions have been successfully removed."
    else
      flash[:error] = "Something went wrong. Please try again."
    end
    redirect_to parent_edit_path(@parent, page: 'permissions')
  end

  protected

  def pundit_authorize
    self.policy = ActorPolicy.new(current_user, @parent)
    authorize @parent
  end
end
