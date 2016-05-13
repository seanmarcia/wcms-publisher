// Pass a jQuery object as the parameter
// This should be available at the root scope
resetDatetimePicker = function (object) {
  if (object.length > 0) {
    object.datetimepicker({
      useCurrent: false,
      sideBySide: true,
      icons: {
        time: 'fa fa-clock-o',
        date: 'fa fa-calendar',
        up: 'fa fa-chevron-up',
        down: 'fa fa-chevron-down',
        previous: 'fa fa-chevron-left',
        next: 'fa fa-chevron-right',
        today: 'fa fa-dot-circle-o',
        clear: 'fa fa-trash',
        close: 'fa fa-times'
      },
    })
  }
}

$(document).ready(function () {
  resetDatetimePicker($('.datetimepicker'));
});
