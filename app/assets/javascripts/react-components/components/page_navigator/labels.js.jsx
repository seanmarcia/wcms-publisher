PageNavigator.StatusLabel = React.createClass({
  propTypes: {
    status: React.PropTypes.string
  },
  render: function() {
    var label = {};
    switch (this.props.status) {
      case 'published':
        label = {className: "label label-success", title: 'Published'}
        break;
      case 'archived':
        label = {className: "label label-warning", title: 'Archived'}
        break;
      case 'request_review':
        label = {className: "label label-info", title: 'Up for Review'}
        break;
      default:
        label = {className: "label label-default", title: 'Draft'}
        break;
    }
    return <span className={label.className}>{label.title}</span>
  }
})


PageNavigator.RedirectLabel = React.createClass({
  propTypes: {
    url: React.PropTypes.string
  },
  render: function () {
    if (this.props.url) {
      return <span className="label label-danger" title={this.props.url}>Redirected</span>
    } else {
      return null;
    }
  }
})
