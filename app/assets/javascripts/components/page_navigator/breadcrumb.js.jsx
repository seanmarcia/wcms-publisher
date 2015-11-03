PageNavigator.Breadcrumb = React.createClass({
  propTypes: {
    page: React.PropTypes.object,
    onClickBreadcrumb: React.PropTypes.func
  },
  handleClick: function() {
    this.props.onClickBreadcrumb(this.props.page);
  },
  render: function() {
    return <li onClick={this.handleClick}>{this.props.page.attributes.title}</li>
  }
})
