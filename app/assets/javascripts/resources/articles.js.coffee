$(document).ready ->
  if $('div.articles').length > 0
    $('#tags-topic').tagsInput()

    $('#tags-autocomplete').tagsInput
      autocomplete_url: $('.people_search').data('source')
