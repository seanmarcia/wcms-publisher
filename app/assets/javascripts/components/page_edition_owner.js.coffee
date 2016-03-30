update_selectables = (thing) ->
  $(".source_select").hide()
  $("#"+thing).show()

$(document).ready ->
  $(".source_select").hide()
  if source_type =  $("#source_type").val()
    update_selectables(source_type)

  # This should get fired once a source has been manually selected
  $("#source_type").change ->
    update_selectables(this.value)
