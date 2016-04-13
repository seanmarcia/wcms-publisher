module ActionView
  module Helpers
    class FormBuilder
      # Overwrite default date and datetime selectors with bootstrap datepicker
      def date_select(method, options = {}, html_options = {})
        existing_date = @object.send(method)
        formatted_date = existing_date.to_date.strftime("%F") if existing_date.present?
        @template.content_tag(:div, :class => "input-group datepicker") do
          text_field(method, :value => formatted_date, :class => "form-control", :"data-date-format" => "YYYY-MM-DD") +
          @template.content_tag(:span, @template.content_tag(:i, "", :class => "fa fa-calendar") ,:class => "input-group-addon")
        end
      end

      def datetime_select(method, options = {}, html_options = {})
        existing_time = @object.send(method)
        formatted_time = existing_time.to_time.strftime("%F %I:%M %p") if existing_time.present?
        @template.content_tag(:div, :class => "input-group datetimepicker") do
          text_field(method, :value => formatted_time, :class => "form-control", :"data-date-format" => "YYYY-MM-DD hh:mm A") +
          @template.content_tag(:span, @template.content_tag(:i, "", :class => "fa fa-calendar") ,:class => "input-group-addon")
        end
      end
    end
  end
end
