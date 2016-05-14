determineLocationType = (location_type) ->
  if location_type == 'on-campus'
    $('#off_campus').hide()
    $('#on_campus').show()
  else if location_type == 'off-campus'
    $('#off_campus').show()
    $('#on_campus').hide()
  else
    $('#off_campus').hide()
    $('#on_campus').hide()


$(document).ready ->
  if $("body[data-controller='events']").length > 0
    if location_type = $('#event_location_type').val()
      determineLocationType(location_type)

    $('#event_location_type').change ->
      determineLocationType(this.value)


    # Event Links
    $(".add_link_button").click (e) -> #on add input button click
      e.preventDefault()
      $(".input_link_fields_wrap").append "<div class=\"input_link_fields\"><input class=\"form-control link_url\" placeholder=\"Title\" name=\"links[#{Date.now()}][title]\" type=\"text\" value=\"\" style=\"display: inline;\"/>
      <input class=\"form-control link_url\" placeholder=\"Url\" name=\"links[#{Date.now()}][url]\" type=\"text\" value=\"\"/>
      <a href=\"#\" class=\"remove_field\">Remove</a></div>" #add input box

    $(".input_link_fields_wrap").on "click", ".remove_field", (e) -> #user click on remove text
      e.preventDefault()
      $(this).parent("div").remove()


    $('form').on 'click', '.add_fields', (event) ->
      time = new Date().getTime()
      regexp = new RegExp($(this).data('id'), 'g')
      $(this).before($(this).data('fields').replace(regexp, time))
      resetDatetimePicker($('.datetimepicker'))
      event.preventDefault()
