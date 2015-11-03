// Set params variable with URL parameters
var params = {}
window.location.search.substring(1).split('&').forEach(function(v) {
  var param = v.split('=');
  params[param[0]] = param[1];
});
