(function () {

  // Imports
  var NotificationStore = App.stores.NotificationStore;

  // Styles
  var NotificationsStyles = {
    position: 'fixed',
    top: 20,
    right: 20,
    width: 300
  }

  App.components.Bootstrap.Notifications = React.createClass({
    propTypes: {
      notifications: React.PropTypes.array,
    },

    _notifications: function () {
      return this.props.notifications.map(function (n) {
        var c = n.error ? 'alert alert-danger' : 'alert alert-info';

        return <div className={c} key={n.id} >
          {n.text}
        </div>
      })
    },

    render: function () {
      return <div style={NotificationsStyles}>
        {this._notifications()}
      </div>
    },

  })

})();
