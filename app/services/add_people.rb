# Add authors, related people and the like. Generally used with people_search
#
# @example
#   AddPeople.new(@article, params[:a], 'authors', {allow_blank: true}).add_related_people
#
class AddPeople
  include ServiceObject
  attr_accessor :object, :people_ids, :intent, :options

  def initialize(object, people_ids, intent, options = {})
    unless (people_ids.present? || options[:allow_blank].present?) && object.respond_to?(intent)
      return []
    end

    @options = options
    @object = object
    @intent = intent

    # clean out possible non-ids
    #  ref: https://github.com/Automattic/mongoose/issues/1959
    @people_ids = people_ids.delete_if { |id| !id.match(/^[0-9a-fA-F]{24}$/) }
  end

  # Set relationship using the original array of ids to maintain order.
  def add_related_people
    @object.send("#{intent.singularize}_ids=", people_ids) if intent.present?
  end
end
