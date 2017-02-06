### Description ###
# jQuery plugin to dynamically create multiple fields.
# Typically used to support input for backend array data types.

### Example: ###
# <div class="array-input">
#   <div class="list">
#     <!-- render inputs for existing array elements here -->
#   </div>
#   <input type="text" name="article[tags][]" value=""/>
#   <button type="button">Add</button>
# </div>
# <script>$('.array-input').arrayInput()</script>

(($) ->
  $.fn.arrayInput = ->
    this.each (i, el) ->
      wrapper = $(el)
      list = wrapper.find '.list'
      new_hidden_field = wrapper.find('input[type=hidden]').last()
      new_input = wrapper.find('input[type=text]').last()
      button = wrapper.find('button').last()

      new_input.on 'keypress', (e) ->
        if e.which == 13
          append_field list, new_hidden_field, e
          append_field(list, new_input, e)
      button.on 'click', (e) ->
        append_field(list, new_hidden_field, e)
        append_field(list, new_input, e)

  append_field = (list, new_input, e) ->
    added_input = new_input.clone()
    added_input.attr 'style', ''

    added_input.appendTo list
    new_input.val ''

    e.preventDefault()
    false

) jQuery
