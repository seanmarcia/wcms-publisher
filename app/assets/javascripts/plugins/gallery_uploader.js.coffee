$(document).ready ->
  $(".add_gallery_photo_button").click (e) -> #on add input button click
    e.preventDefault()
    $(".input_gallery_photo_fields_wrap").append "<div><input type=\"file\" name=\"gallery_photos[#{Date.now()}][photo]\" style=\"display: inline;\"/>
    <input class=\"form-control gallery_photo_caption\" placeholder=\"Caption\" name=\"gallery_photos[#{Date.now()}][caption]\" type=\"text\" value=\"\"/>
    <a href=\"#\" class=\"remove_field\">Remove</a></div>" #add input box

  $(".input_gallery_photo_fields_wrap").on "click", ".remove_field", (e) -> #user click on remove text
    e.preventDefault()
    $(this).parent("div").remove()
