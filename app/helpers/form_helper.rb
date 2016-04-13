module FormHelper
  def permitted_form_for(object, options = {}, &block)
    options[:builder] = PermittedFormBuilder
    form_for(object, options, &block)
  end
end
