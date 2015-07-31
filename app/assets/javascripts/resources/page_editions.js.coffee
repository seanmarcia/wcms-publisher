$(document).ready ->
  if ($("#page-edition-template").length > 0)
    source = $("#page-edition-template").html()
    template = Handlebars.compile(source)
    selectedNode = {}

    findNode = (node_id) ->
      page_editions_tree.find((el) -> el.id == node_id)

    parentNode = (node_id) ->
      if node = findNode(node_id)
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
      children = page_editions_tree.filter (el) -> el.parent_id == node_id

    resetTreeView = ->
      html = template
        breadcrumbs: breadcrumbs(selectedNode.id, true)
        node: selectedNode

      # Send the rendered template to the DOM
      $('#page_tree').html(html)

    refreshNode = ->
      # Get node id from the url Hash. This way page history works.
      node_id = document.location.hash.substring(1) || "sites"
      selectedNode = findNode(node_id)

      # Cache child pages into selected node.
      selectedNode.pages ||= childPages(node_id)
      resetTreeView()

    # $('#page_tree').on 'click', 'a', -> refreshNode()
    window.onpopstate = (event) -> refreshNode()
    refreshNode()
