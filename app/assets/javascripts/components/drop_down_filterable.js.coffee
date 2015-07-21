preselected_categories_exist = -> typeof preselected_categories isnt "undefined"

category_is_selected = (category_id) ->
  preselected_categories_exist() && $.inArray(category_id, preselected_categories) >= 0

determineCategories = (site_id) ->
  selected_site_categories = []

  # Site categories is defined in the view
  categories = site_categories[site_id]
  categories.forEach (category) ->
    selected_site_categories.push
      label: category.title
      title: category.title
      value: category.id
      selected: category_is_selected(category.id)

  $(".multi_category_select select").multiselect "dataprovider", selected_site_categories


$(document).ready ->
  if site_id = $(".site_multiselect").val() || $("#disabled_site_id").val()
    determineCategories(site_id)

  # This should get fired once a site has been manually selected
  $(".site_multiselect").change ->
    determineCategories(this.value)

