(function () {
  _notifications = [];

  // All the properties here get copied into the App.stores.NotificationStore object
  NotificationStore = Object.assign(App.stores.NotificationStore, EventEmitter.prototype, {

    push: function (text, isError) {
      // Support text being an array
      if (typeof(text) == 'object') {
        text.forEach(function (t) {
          NotificationStore.push(t, isError)
        })
      } else {
        var newMessage = {
          id: guid(),
          text: text,
          error: !!isError,
        };

        _notifications.push(newMessage);
        NotificationStore.emit('change');

        setTimeout(function () {
          NotificationStore.remove(newMessage)
        }, 5000)
      }
    },

    pushError: function (text) {
      this.push(text, true);
    },

    remove: function (notification) {
      var index = _notifications.indexOf(notification);
      if (index > -1) {
        _notifications.splice(index, 1);
        NotificationStore.emit('change');
      }
    },

    getAll: function () {
      return _notifications;
    }

  });
})();
