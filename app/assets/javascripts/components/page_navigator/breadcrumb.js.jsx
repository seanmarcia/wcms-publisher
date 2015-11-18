PageNavigator.Breadcrumb = React.createClass({
  propTypes: {
    id: React.PropTypes.string,
    title: React.PropTypes.string
  },
  isActive: function () {
    // Force null id to be empty string since that is what the hash substring will be.
    return document.location.hash.substring(1) == (this.props.id || "")
  },
  render: function () {
    if (this.isActive()) {
      return <li className="active">{this.props.title}</li>
    } else {
      return <li><a href={"#"+this.props.id}>{this.props.title}</a></li>
    }
  }
})
