$(document).ready ->
  if $('body.gallery_photos.index').length > 0
    $('form.primary').on 'click', (e) ->
      e.target.form.submit()
