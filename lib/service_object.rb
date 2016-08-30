module ServiceObject
  Result = ImmutableStruct.new(:success?, [:errors], :html_safe_errors)

  def initialize
    @errors = []
  end

  def print_errors
    puts @errors
  end

  private

  attr_accessor :errors, :log_messages

  def html_safe_errors
    html = ""
    html << "<ul>"
    @errors.each do |error|
      html << html_error_list_item(error)
    end
    html << "</ul>"
    html
  end

  def html_error_list_item(error)
    "<li>#{error}</li>"
  end

  def result_with_errors(additional_error=nil)
    @errors << additional_error if additional_error.present?
    Result.new success: false, errors: errors, html_safe_errors: html_safe_errors
  end

  def result_with_success
    Result.new success: true
  end

end
