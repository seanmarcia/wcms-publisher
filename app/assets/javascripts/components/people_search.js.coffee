# Currently being used for articles and external articles.
# I want to eventually replace this with the component person search, but it doesn't
#   Support multiple people per field.

$(document).ready ->
  # This does an ajax search (through the members controller) to query ws and get a list of matching people to autocomplete.
  if $(".people_search").length > 0
    $(".people_search").autocomplete(
      source: (query, response) ->
        $.ajax $(".people_search").data('source'),
          data:
            query: query.term

          dataType: "json"
          success: (data) ->
            response $.map(data, (person) ->
              label: (person.first_name + ' ' + person.last_name)
              value: person.biola_email
              thumb: person.biola_photo_url
              department: person.department
              affiliations: person.affiliations.join(", ")
            )
      messages:
        noResults: ""
        results: ->
    )

    # To support multiple forms on each page you need to iterate through each one.
    #   http://stackoverflow.com/questions/11415691/jquery-autocomplete-renderitem-issue-with-multiple-inputs-to-trigger-autocomple
    $(".people_search").each ->
      $(this).data("ui-autocomplete")._renderItem = (ul, item) ->
        img = if item.thumb then $("<img>").attr("src", item.thumb) else ''
        dep = if item.department then $("<div class='department'></div>").text(item.department) else ''
        link = $("<a>").prepend(img).append($("<div class='person_details'></div>").text(item.label).append(dep).append($("<span class='affiliation'></span>").text(item.affiliations)))
        $("<li>").data("item.autocomplete", item).append(link).appendTo ul
