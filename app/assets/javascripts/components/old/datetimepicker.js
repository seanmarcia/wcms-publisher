//
// To use the bootstrap-datetime picker field, just use one of
// the rails FormBuilder helpers we created.
// - date_select(method, options = {}, html_options = {})
// - datetime_select(method, options = {}, html_options = {})
//
// Example:
//   = f.datetime_select :field_name
// or
//   = f.date_select :field_name
//
//
// `defineDateTimeRangeGroup` links two fields to enforce one is
// always an earlier date than the other one.
//
// @param rangeGroups [jQueryObject]
//   This should be the parent DOM element that contains both
//   the `date-from` and the `date-to` elements
//
// Example usage:
//  .date-time-range-group
//    = f.datetime_select :publish_at, {}, class: 'date-from'
//    = f.datetime_select :archive_at, {}, class: 'date-to'
//
defineDateTimeRangeGroup = function (rangeGroups) {
  if (rangeGroups.length > 0) {
    // Support multiple groups defined on the page
    // Loop through each one.
    rangeGroups.each(function(i, element) {
      var fromDate = $(element).find('.date-from');
      var toDate = $(element).find('.date-to');

      // Skip if we can't find elements for both sides of the range
      // inside the range group element.
      if (fromDate.length == 1 && toDate.length == 1) {
        // Initialize on page load
        var initialFromDate = fromDate.find('input').val();
        var initialToDate = toDate.find('input').val()
        if (initialFromDate) {
          toDate.data('DateTimePicker').minDate(moment(initialFromDate));
        }
        if (initialToDate) {
          fromDate.data('DateTimePicker').maxDate(moment(initialToDate));
        }

        // Update whenever the field values change
        fromDate.on('dp.change', function (e) {
          toDate.data('DateTimePicker').minDate(e.date);
        });
        toDate.on('dp.change', function (e) {
          fromDate.data('DateTimePicker').maxDate(e.date);
        });
      }
    })
  }
}

//
// `resetDatetimePicker` initializes all the datetime pickers on the page.
//
// @param object [jQueryObject]
//   This is the element you want to initialize
// @public This function should be available globally
//
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
  defineDateTimeRangeGroup($('.date-time-range-group'));
});
