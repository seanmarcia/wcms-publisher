$(document).ready ->
  $('#example-button').click ->
    if $('#example-button').text() == 'Show Example'
      $('#example-button').text('Hide Example')
      $('#example').show()
    else if $('#example-button').text() == 'Hide Example'
      $('#example-button').text('Show Example')
      $('#example').hide()
