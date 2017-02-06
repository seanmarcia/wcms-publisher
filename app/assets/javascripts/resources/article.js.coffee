$(document).ready ->
  if $('body .edit_article').length > 0
    $('.array-input .author button.delete').on 'click', (e) ->
      wrapper = $(e.currentTarget).parents('.author')
      wrapper.find('input[type=hidden]').val('')
      wrapper.slideUp()
