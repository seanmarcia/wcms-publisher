$(document).ready ->
  # this is a small hack; when a tr is dragged with jQuery UI sortable
  # the cells lose their width
  if row = $('.table-sortable').find('tr')[0]
    cells = row.cells.length
    desired_width = 1200 / cells + 'px'
    $('.table td:not(.ignore-width)').css('width', desired_width)

  $('.table-sortable').sortable
    handle: '.handle'
    axis: 'y'
    items: '.sortable-item'
    update: -> $.post($(this).data('update_url'), $(this).sortable('serialize'))
