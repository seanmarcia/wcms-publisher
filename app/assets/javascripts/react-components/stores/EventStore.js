(function () {
  // Imports
  var EventAPI = App.utils.EventAPI;
  var NotificationStore = App.stores.NotificationStore;

  _events = {};
  _status = null;

  // All the properties here get copied into the App.stores.EventStore object
  EventStore = Object.assign(App.stores.EventStore, EventEmitter.prototype, {

    /**
     * Getters
     */
    get: function(id) {
      return _events[id];
    },

    getAll: function() {
      var items = [];
      for (var key in _events) {
        items.push(_events[key]);
      }

      items.sort(function(a,b) {
        if (a.start_date < b.start_date) {
          return -1;
        } else if (a.start_date > b.start_date) {
          return 1;
        }
        return 0;
      });
      return items
    },


    /**
     * Actions
     */
    loadFromAPI: function (options) {
      EventAPI.index(options, function (data) {
        Object.assign(_events, data);
        EventStore.emit('change');
      })
    },

    updateEvent: function (id, params, callback) {
      EventAPI.update(id, { event: params }, function (data) {
        if (data.success) {
          NotificationStore.push('Changes saved');
        } else {
          NotificationStore.pushError(data.errors);
        }
      })
    }
  });
})();
