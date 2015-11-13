(function () {

  var styles = {
    padding: 10,
    marginBottom: 5,
    boxShadow: "0 1px 3px rgba(0,0,0,0.12), 0 1px 2px rgba(0,0,0,0.24)",
    border: 'none'
  }

  Notifier.Alert = React.createClass({
    propTypes: {
      text: React.PropTypes.object
    },
    render: function () {
      return <div style={styles} className="alert alert-info">{this.props.alert.text}</div>
    }
  })

})()
