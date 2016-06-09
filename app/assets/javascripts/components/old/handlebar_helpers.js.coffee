$(document).ready ->
  Handlebars.registerHelper 'breadcrumb', ->
    string = if this.active
      "<li class='active'>#{this.title}</li>"
    else
      id = this.id || ''
      "<li><a href='##{id}'>#{this.title}</a></li>"
    new Handlebars.SafeString(string)

  Handlebars.registerHelper 'status_tag', (node) ->
    status = switch node.status
      when "published" then ["success", "Published"]
      when "archived" then ["warning", "Archived"]
      when "ready_for_review" then ["info", "Up for Review"]
      else ["default", "Draft"]
    if node.type == "PageEdition"
      new Handlebars.SafeString("<span class='label label-#{status[0]}'>#{status[1]}</span>")

  Handlebars.registerHelper 'linkto', (title, url) ->
    # the `this` object gets passed into url if you only pass one parameter
    url = title if typeof(url) == "object"
    new Handlebars.SafeString("<a href='#{url}'>#{title}</a>")

  Handlebars.registerHelper 'linktoif', (title, url) ->
    new Handlebars.SafeString("<a href='#{url}'>#{title}</a>") if url

  Handlebars.registerHelper 'ifequals', (lvalue, rvalue, options) ->
    if arguments.length < 3
      throw new Error("Handlebars Helper equal needs 2 parameters")
    if lvalue == rvalue
      return options.fn(this)
    else
      return options.inverse(this)
