var PageEdition = {
  siteId: window.params.site_id,
  data: {},
  links: {
    show: function (params) { return "/api/page_editions/" + params.id },
    index: function (params) { return "/api/page_editions" + PageEdition.links.params(params); },
    params: function (params) {
      // Should always scope by the site id
      params.site_id = PageEdition.siteId;

      return '?' + $.param(params || {});
    }
  },

  initialize: function (id, callback) {
    // Load just the item
    if (id) {
      Ajax.getAll(this.links.index({id: id}), this, callback);
    };
    // Load all the child pages for that item
    Ajax.getAll(this.links.index({parent_page_id: id}), this, callback);
    // Load al the pages
    Ajax.getAll(this.links.index({all: true}), this, callback);
  }
}
