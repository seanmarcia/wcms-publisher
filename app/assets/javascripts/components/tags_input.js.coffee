$(document).ready ->
  $('.tags-input:enabled').each ->
    $(this).tagsInput
      autocomplete_url: $(this).data('source')
      placeholderColor: '#999999'
      'width': $(this).data('width')
      'delimiter': '|'
      'defaultText': $(this).data('text')
