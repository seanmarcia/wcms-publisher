var Ajax = {
  // Wrapper around jQuery.ajax method for accessing api
  loader: function (url, success) {
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

  // Adds each item returned by the api to scope.data object.
  // It uses item.id as the key for referencing each item in scope.data.
  getAll: function (url, scope, callback) {
    Ajax.loader(url, function(response) {
      response.data.forEach(function(item) {
        scope.data[item.id] = item;
      })
      if (callback) { callback(); }
    });
  }

}
