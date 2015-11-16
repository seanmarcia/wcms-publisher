module SetModifier
  extend ActiveSupport::Concern

  included do
    # Assign modifier needs to be called on any action that results in a db update. Compare to the routes file.
    #  If the controller in question doesn't have a method listed then it won't hit the filter.
    before_filter :assign_modifier, only: [:create, :update, :destroy, :create_tag]
  end

  private

  def assign_modifier
    # This will need to be updated with each new class addition
    [:page_edition, :calendar, :important_date, :campus_location, :menu, :site].each do |name|
      if params[name].present?
        params[name][:modifier_id] = current_user.id.to_s
      end
    end
  end
end
