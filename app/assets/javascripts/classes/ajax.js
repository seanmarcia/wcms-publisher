var Ajax = {
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

  getAll: function (url, scope, callback) {
    Ajax.loader(url, function(response) {
      response.data.forEach(function(item) {
        scope.data[item.id] = item;
      })
      if (callback) { callback(); }
    });
  }

}
