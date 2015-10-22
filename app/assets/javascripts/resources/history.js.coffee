$(document).ready ->
  $('.change_history ul.changes').each ->
    if $(this).children().length > 2
      $(this).children('li').slice(2).hide()
      $(this).children('a').show()

      $(this).children('a').click ->
        $(this).siblings('li').show()
        $(this).hide()


# $(document).ready ->
#   $('ul.changes').click 'a.toggle_changes', (event) ->
#     link = $(event.target)
#     link.siblings('li').show()
#     link.hide()
#     false


#   $('.change_history ul.changes').each ->
#     ul = $(this)
#     if ul.children().length > 2
#       ul.children('li').slice(2).hide()
#       ul.append('<a class="show_more_link" href="#">Expand</a>')


# this needs to be improved-n-stuff
# $(document).ready ->
#   $('ul.changes').on 'click', 'a.toggle_changes', (event) ->
#     $(this).toggleClass('expanded')
#     link = $(event.target)
#     # link.siblings('li').show()
#     link.text('Collapse')
#     false


#   $('.change_history ul.changes').each ->
#     ul = $(this)
#     if ul.children().length > 2
#       # ul.children('li').slice(2).hide()
#       ul.append('<a class="toggle_changes" href="#">Expand</a>')


