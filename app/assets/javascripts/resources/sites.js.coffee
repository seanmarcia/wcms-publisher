$(document).ready ->
  if ($("#subpage-template").length > 0)
    # Register partials
    Handlebars.registerPartial('nodeList', $("#node-list").html());

    # Register template
    template = Handlebars.compile($("#subpage-template").html())
    selectedNode = {}

    # Return all the children of a given node
    childPages = (node_id) -> page_editions.filter (el) -> el.parent_id == node_id

    # Find the node with the given id
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
      node = findNode(node_id)
      if node
        breadcrumbs(node.parent_id).concat [{
          title: node.title
          id: node.id
          active: first
        }]
      else
        []

    refreshNodeBrowser = ->
      # Get node id from the url Hash. This way page history works.
      node_id = document.location.hash.substring(1) || null
      selectedNode = findNode(node_id)

      # Feed data into template and render html
      html = template
        breadcrumbs: breadcrumbs(selectedNode.id, true)
        parent_node: parentNode(selectedNode)
        node: selectedNode
        site_id: site_id

      # Send the rendered template to the DOM
      $('#node_browser').html(html)

    window.onpopstate = (event) -> refreshNodeBrowser()
    refreshNodeBrowser()
