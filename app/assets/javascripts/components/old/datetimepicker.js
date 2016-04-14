// Pass a jQuery object as the parameter
// This should be available at the root scope
resetDatetimePicker = function (object) {
  if (object.length > 0) {
    object.datetimepicker({
      useCurrent: false,
      sideBySide: true,
      icons: {
        time: "fa fa-clock-o",
        date: "fa fa-calendar",
        up: "fa fa-arrow-up",
        down: "fa fa-arrow-down"
      }
    })
  }
}

$(document).ready(function () {
  resetDatetimePicker($('.datetimepicker'));
});
