$(document).ready ->
  $('#example-button').click ->
    if this.text == 'Show Example'
      this.text = 'Hide Example'
      $('#example').show()
    else if this.text == 'Hide Example'
      this.text = 'Show Example'
      $('#example').hide()
