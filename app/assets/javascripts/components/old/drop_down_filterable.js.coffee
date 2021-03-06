# page_editions
preselectedPagesExist = -> typeof preselected_pages isnt "undefined"

pageIsSelected = (page_id) ->
  preselectedPagesExist() && $.inArray(page_id, preselected_pages) >= 0

determinePages = (site_id) ->
  selected_site_page_editions = []

  # Site categories is defined in the view
  categories = page_editions[site_id]
  categories.forEach (page) ->
    selected_site_page_editions.push
      label: page.title
      title: page.title
      value: page.id
      selected: pageIsSelected(page.id)

  $(".multi_page_select select").multiselect "dataprovider", selected_site_page_editions

# site_categories
preselectedCategoriesExist = -> typeof preselected_categories isnt "undefined"

categoryIsSelected = (category_id) ->
  preselectedCategoriesExist() && $.inArray(category_id, preselected_categories) >= 0

setIcons = ->
  if $('.bs-multiselect').length > 0
    $('i.glyphicon.glyphicon-search').removeClass('glyphicon glyphicon-search').addClass('fa fa-search');
    $('i.glyphicon.glyphicon-remove-circle').removeClass('glyphicon glyphicon-remove-circle').addClass('fa fa-times-circle');

determineCategories = (site_id) ->
  selected_site_categories = []

  # Site categories is defined in the view
  if categories = site_categories[site_id]
    categories.forEach (category) ->
      selected_site_categories.push
        label: category.title
        title: category.title
        value: category.id
        selected: categoryIsSelected(category.id)

  $(".multi_category_select select").multiselect "dataprovider", selected_site_categories


$(document).ready ->
  if site_id = $(".site_multiselect").val() || $("#disabled_site_id").val()
    if preselectedCategoriesExist()
      determineCategories(site_id)
    if preselectedPagesExist()
      determinePages(site_id)
    setIcons()
  else
    $(".multi_category_select").hide()

  # This should get fired once a site has been manually selected
  $(".site_multiselect").change ->
    $(".multi_category_select").show()
    if preselectedCategoriesExist()
      determineCategories(this.value)
    if preselectedPagesExist()
      determinePages(this.value)
    setIcons()

