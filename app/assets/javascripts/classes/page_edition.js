var PageEdition = {
  siteId: window.params.sid,
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
  },

  pagesWhere: function (conditionFunc) {
    var results = [];
    for (id in this.data) {
      // Pass page into condition function. The condition function should return either
      // true or false whether you want the page to be included
      if (conditionFunc(this.data[id])) { results.push(this.data[id]); }
    }
    return results;
  },
  childPages: function (parentId) {
    return this.pagesWhere(function(page) {
      return page.attributes.parent_page_id == parentId;
    });
  },
  search: function (searchParams, selectedId) {
    var searchExp = null;
    if (searchParams.text) {
      searchExp = new RegExp(searchParams.text.replace(" ", ".*"), 'i');
    }

    return this.pagesWhere(function(page) {
      return (
        // If searchParams.all is not true, filter to only child pages of the selectedId
        (!!searchParams.all || page.attributes.parent_page_id == selectedId) &&

        // Compare filters
        (!searchParams.status || searchParams.status == page.attributes.status) &&
        (!searchParams.redirect || page.attributes.redirect_url) &&
        (!searchParams.text || (page.attributes.slug.match(searchExp) || page.attributes.title.match(searchExp)))
      );
    });
  }
}
