(function () {

  App.utils.Ajax = {
    // Wrapper around jQuery.ajax method for accessing api
    loader: function (url, method, success) {
      $.ajax({
        url: url,
        dataType: 'json',
        method: method,
        cache: false,
        success: success,
        error: function(xhr, status, err) {
          console.error(url, status, err.toString());
        }
      });
    },

    // Adds each item returned by the api to scope.data object.
    // It uses item.id as the key for referencing each item in scope.data.
    getAll: function (url, target, callback) {
      if (!target) { target = {}; }
      Ajax.loader(url, 'GET', function(response) {
        response.data.forEach(function(item) {
          target[item.id] = item;
        })
        if (callback) { callback(target); }
      });
    },

    put: function (url, data, success, error) {
      $.ajax({
        url: url,
        dataType: 'json',
        method: 'PUT',
        data: data,
        success: success,
        error: error,
      });
    },

  }

})();
