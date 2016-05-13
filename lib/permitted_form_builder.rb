class PermittedFormBuilder < ActionView::Helpers::FormBuilder
  EXCLUDED_HELPERS = [:label, :check_box, :fields_for, :hidden_field]
  EXTRA_HELPERS = [:select]

  delegate :content_tag, :text_field_tag, :safe_concat, :fa_icon, to: :@template

  (field_helpers - EXCLUDED_HELPERS + EXTRA_HELPERS).each do |method_name|
    define_method(method_name) do |name, *args, &block|
      options = args.extract_options!
      options[:disabled] = true if options[:disabled].nil? && policy.cant_change?(name)

      add_attribute name

      super(name, *args, options, &block)
    end
  end

  def check_box(name, options = {}, checked_value = '1', unchecked_value = '0')
    options[:disabled] = true if policy.cant_change?(name)

    add_attribute name

    super(name, options, checked_value, unchecked_value)
  end

  def array_fields(name, options = {})
    disabled =
      if options[:disabled].nil?
        policy.cant_change?(name)
      else
        options[:disabled]
      end

    content_tag :div, class: 'array-input' do
      tags = []

      tags << content_tag(:div, class: 'list') do
        Array(object.send(name)).map do |element|
          text_field_tag "#{object_name}[#{name}][]", element, class: 'form-control', disabled: disabled
        end.join.html_safe
      end

      tags << content_tag(:div, class: 'form-inline') do
        [
          text_field_tag("#{object_name}[#{name}][]", nil, class: 'form-control', style: 'width: 80%;', disabled: disabled),
          content_tag(:button, class: 'btn btn-success add', type: :button, disabled: disabled) { fa_icon('plus') }
        ].join(' ').html_safe
      end

      tags.join("\n").html_safe
    end
  end

  def submit(value=nil, options={})
    if object.new_record? && policy.respond_to?(:create?)
      options[:disabled] ||= true unless policy.create? && any_permitted?
    elsif object.persisted? && policy.respond_to?(:update?)
      options[:disabled] ||= true unless policy.update? && any_permitted?
    end

    super(value, options)
  end

  private

  def attributes
    @attributes ||= []
  end

  def add_attribute(name)
    attributes << name
  end

  def any_permitted?
    (policy.permitted_attributes & attributes).any?
  end

  def policy
    @policy ||= @template.policy(object)
  end
end
