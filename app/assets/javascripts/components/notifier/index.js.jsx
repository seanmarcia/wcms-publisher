//= require ./notifier
//= require ./alert

$(document).ready(function() {
  var node = document.createElement("div");
  document.body.appendChild(node);
  ReactDOM.render(<Notifier alerts={Notification.all} />, node);

  // React doesn't keep track of changes outside of itself, so we need
  // to setup a callback inside Notification to handle this
  Notification.updateCallbacks.push(function(alerts) {
    ReactDOM.render(<Notifier alerts={Notification.all} />, node);
  })
});
