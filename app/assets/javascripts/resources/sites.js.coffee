$(document).ready ->
  if ($("#subpage-template").length > 0)
    # Register partials
    Handlebars.registerPartial('nodeList', $("#node-list").html());

    # Register template
    template = Handlebars.compile($("#subpage-template").html())
    selectedNode = {}

    findNode = (node_id) ->
      if node = page_editions.find((el) -> el.id == node_id)
        # Cache child pages into selected node.
        node.pages ||= childPages(node.id)
      node

    parentNode = (node_id) ->
      node = if typeof(node_id) == "number" then findNode(node_id) else node_id
      if node
        findNode(node.parent_id)

    breadcrumbs = (node_id, first) ->
      if node_id
        node = findNode(node_id)
        breadcrumbs(node.parent_id).concat [{
          title: node.title
          id: node.id
          active: first
        }]
      else
        []

    childPages = (node_id) ->
      children = page_editions.filter (el) -> el.parent_id == node_id

    resetPageBrowser = ->
      html = template
        breadcrumbs: breadcrumbs(selectedNode.id, true)
        parent_node: parentNode(selectedNode)
        node: selectedNode

      # Send the rendered template to the DOM
      $('#node_browser').html(html)

    refreshNodeBrowser = ->
      # Get node id from the url Hash. This way page history works.
      node_id = document.location.hash.substring(1) || "site"
      selectedNode = findNode(node_id)
      resetPageBrowser()

    # $('#node_browser').on 'click', 'a', -> refreshNodeBrowser()
    window.onpopstate = (event) -> refreshNodeBrowser()
    refreshNodeBrowser()
