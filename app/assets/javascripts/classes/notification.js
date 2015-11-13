var Notification = {
  all: [],
  lastId: 0,
  updateCallbacks: [],

  new: function (message) {
    var notification = {
      id: (this.lastId += 1),
      text: message
    };
    this.all.push(notification);
    this.onUpdate();
    this.queueRemoval(notification);
    return this.all;
  },

  queueRemoval: function (notification) {
    var _this = this;

    // remove notification after 5 seconds
    setTimeout(function() {
      var index = _this.all.indexOf(notification);
      _this.all.splice(index, 1);
      _this.onUpdate();
    }, 5000);
  },

  onUpdate: function () {
    // Loop through all the callbacks and pass `all` as the argument
    this.updateCallbacks.forEach(function(callback) {
      callback(Notification.all);
    })
  }
}
