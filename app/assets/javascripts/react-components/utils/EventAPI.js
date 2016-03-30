(function () {
  Ajax = App.utils.Ajax;

  EventAPI = Object.assign(App.utils.EventAPI, {
    links: {
      index: function (params) { return "/events" + EventAPI.links.params(params) },
      show: function (id) { return "/events/" + id },
      update: function (id) { return "/events/" + id },
      params: function (params) { return '?' + $.param(params || {}) },
    },

    index: function (options, callback) {
      params = {};
      // Whitelist parameters
      if (options.future) { params.future = true; }
      if (options.id) { params.id = options.id; }
      if (options.limit) { params.limit = options.limit; }
      if (options.show_details) { params.show_details = options.show_details; }

      Ajax.getAll(this.links.index(params), {}, callback);
    },

    update: function (id, params, success, error) {
      Ajax.put(this.links.update(id), params, success, error);
    },
  });

})();
