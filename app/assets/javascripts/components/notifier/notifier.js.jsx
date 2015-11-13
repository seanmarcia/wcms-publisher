(function () {

  var styles = {
    position: 'fixed',
    top: 20,
    right: 20,
    width: '40%',
    minWidth: 200,
    zIndex: 100
  }

  window.Notifier = React.createClass({
    propTypes: {
      alerts: React.PropTypes.array.isRequired
    },
    render: function () {
      var alerts = [];
      this.props.alerts.forEach(function(alert) {
        alerts.push(<Notifier.Alert key={alert.id} alert={alert} />);
      });

      return <div style={styles}>{alerts}</div>
    }
  })


})()
