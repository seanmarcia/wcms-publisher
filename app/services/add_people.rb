# Add authors, related people and the like. Generally used with people_search
#
# @example
#   AddPeople.new(@article, params[:a], 'authors').add_related_people
#
class AddPeople
  include ServiceObject
  attr_accessor :object, :people_ids, :intent

  def initialize(object, people_ids, intent)
    return [] unless people_ids.present? && object.respond_to?(intent)
    @object = object
    @intent = intent

    # clean out possible non-ids
    #  ref: https://github.com/Automattic/mongoose/issues/1959
    @people_ids = people_ids.delete_if { |id| !id.match(/^[0-9a-fA-F]{24}$/) }
  end

  # Set relationship using the original array of ids to maintain order.
  def add_related_people
    return unless people_ids
    @object.send("#{intent.singularize}_ids=", people_ids)
  end
end
