var PageEdition = {
  siteId: window.params.site_id,
  data: {},
  links: {
    show: function (params) { return "/api/page_editions/" + params.id },
    index: function (params) {
      return "/api/page_editions" + PageEdition.links.params(params);
    },
    params: function (params) {
      // Should always scope by the site id
      params.site_id = PageEdition.siteId;

      return '?' + $.param(params || {});
    }
  },

  loader: function (linkType, params, success) {
    var url = PageEdition.links[linkType](params);
    $.ajax({
      url: url,
      dataType: 'json',
      cache: false,
      success: success,
      error: function(xhr, status, err) {
        console.error(url, status, err.toString());
      }
    });
  },

  loadChildPages: function (parentId, callback) {
    PageEdition.loader('index', {parent_page_id: parentId}, function(response) {
      response.data.forEach(function(page) {
        PageEdition.data[page.id] = page;
      })
      if (callback) { callback(PageEdition.data); }
    })
  },

  loadAllRan: false,
  loadAll: function (callback) {
    if (!PageEdition.loadAllRan) {
      PageEdition.loadAllRan = true
      PageEdition.loader('index', {all: true}, function(response) {
        response.data.forEach(function(page) {
          PageEdition.data[page.id] = page;
        })
        if (callback) { callback(PageEdition.data); }
      })
    }
  },

  loadPage: function (id, callback) {
    if (!PageEdition.data[id]) {
      PageEdition.loader('show', {id: id}, function(response) {
        PageEdition.data[id] = response.data;
        if (callback) { callback(PageEdition.data); }
      })
    } else {
      if (callback) { callback(PageEdition.data); }
    }
  },

}
