update_selectables = ->
  if $("#page_edition_site_category_ids option").length > 0
    $("#site_category").show()
  else
    $("#site_category").hide()

$(document).ready ->
  $("#site_category").hide()
  if $("#page_edition_site_id").val()
    update_selectables()

  # This should get fired once a source has been manually selected
  $("#page_edition_site_id").change ->
    update_selectables()
