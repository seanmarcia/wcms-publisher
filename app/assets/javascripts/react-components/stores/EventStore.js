(function () {
  // Imports
  var EventAPI = App.utils.EventAPI;

  var CHANGE_EVENT = 'change';
  _events = {};

  // All the properties here get copied into the App.stores.EventStore object
  EventStore = Object.assign(App.stores.EventStore, EventEmitter.prototype, {

    /**
     * EventEmitter setup
     */
    emitChange: function () {
      this.emit(CHANGE_EVENT);
    },
    addChangeListener: function (callback) {
      this.on(CHANGE_EVENT, callback);
    },
    removeChangeListener: function (callback) {
      this.removeListener(CHANGE_EVENT, callback);
    },


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
        EventStore.emitChange();
      })
    },

    updateEvent: function (id, params, callback) {
      EventAPI.update(id, { event: params })
    }
  });
})();
