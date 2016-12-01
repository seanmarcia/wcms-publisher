determineFeatureFields = (feature_type) ->
  if feature_type == 'content_only'
    $('#audio_feature').hide()
    $('#video_feature').hide()
    $('#thumb_url').hide()
    $('.call-to-action').hide()
  else if feature_type == 'video'
    $('#video_feature').show()
    $('#thumb_url').show()
    $('#audio_feature').hide()
    $('.call-to-action').show()
  else if feature_type == 'audio'
    $('#audio_feature').show()
    $('#thumb_url').show()
    $('#video_feature').hide()
    $('.call-to-action').show()
  else
    $('#audio_feature').hide()
    $('#video_feature').hide()
    $('#thumb_url').hide()
    $('.call-to-action').show()

$(document).ready ->
  if $('body').data('controller') == 'features'
    determineFeatureFields(feature_type.value)

    $('#feature_type').change ->
      determineFeatureFields(this.value)
