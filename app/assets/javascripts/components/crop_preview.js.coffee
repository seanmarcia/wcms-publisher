$(document).ready ->
  if $(".crop-modal").length > 0
    class AvatarCropper
      constructor: ->
        $('#cropbox').Jcrop
          aspectRatio: 5 / 3
          setSelect: [0, 0, 600, 600]
          onSelect: @update
          onChange: @update

      update: (coords) =>
        $('#crop_x').val(coords.x)
        $('#crop_y').val(coords.y)
        $('#crop_w').val(coords.w)
        $('#crop_h').val(coords.h)
        @updatePreview(coords)

      updatePreview: (coords) =>
        $('#preview').css
          width: Math.round(100/coords.w * $('#cropbox').width()) + 'px'
          height: Math.round(100/coords.h * $('#cropbox').height()) + 'px'
          marginLeft: '-' + Math.round(100/coords.w * coords.x) + 'px'
          marginTop: '-' + Math.round(100/coords.h * coords.y) + 'px'

    jQuery.fn.center = (img_height, img_width) ->
      if img_height > $(window).height()
        height = 10
      else
        height = ($(window).height() / 2) - (img_height / 2)
        if img_width > $(window).width()
          width = 10
        else
          width = ($(window).width() / 2) - (img_width / 2)
          @css "position", "absolute"
          @css "top", height
          @css "left", width

  #Show image preview
    preview = $(".preview img")
    thumb = $(".thumb img")
    $(".file").change (event) ->
      preview.attr "id", "cropbox"
      input = $(event.currentTarget)
      file = input[0].files[0]
      reader = new FileReader()
      reader.onload = (e) ->
        image_base64 = e.target.result
        preview.attr "src", image_base64
        thumb.attr "src", image_base64
        new AvatarCropper()
        modal_height = preview.outerHeight() + thumb.outerHeight() + 30
        modal_width = preview.outerWidth()
        $(".image_holder").center(modal_height, modal_width)

      reader.readAsDataURL file
      $(".thumb-picker").modal "show"

    $('.btn-modal-dismiss').click ->
      # if you hit cancel, jcrop should be destroyed in case the user picks a different image
      JcropAPI = $('#cropbox').data('Jcrop');
      JcropAPI.destroy();
      $(".btn-file-dismiss").click()

    # if a user hits the 'change' button, you want to destroy the old JCrop
    $(".btn-file input:file").click ->
      JcropAPI = $('#cropbox').data('Jcrop');
      if (JcropAPI != undefined)
        JcropAPI.destroy();
