module FormHelper
  def permitted_form_for(object, options = {}, &block)
    options[:builder] = PermittedFormBuilder
    form_for(object, options, &block)
  end

  def link_to_add_fields(name, f, association)
    new_object = f.object.send(association).klass.new
    id = new_object.object_id
    fields = f.fields_for(association, new_object, child_index: id) do |builder|
      render(association.to_s.singularize + "_fields", f: builder)
    end
    link_to(name, '#', class: "add_fields btn btn-default", data: {id: id, fields: fields.gsub("\n", "")})
  end

  def people_ordered_by_array_of_ids(ids)
    ordering = {}
    ids.each_with_index { |id, i| ordering[id] = i }
    Person.find(ids).sort_by { |o| ordering[o.id] }
  end
end
