PageNavigator.Item = React.createClass({
  propTypes: {
    pages: React.PropTypes.array,
    onSelectPage: React.PropTypes.func
  },
  handleClick: function() {
    this.props.onSelectPage(this.props.page);
  },
  render: function() {
    return (
      <tr onClick={this.handleClick}>
        <td>/{this.props.page.attributes.slug}</td>
        <td>{this.props.page.attributes.title}</td>
        <td><PageNavigator.StatusLabel status={this.props.page.attributes.status} /></td>
      </tr>
    );
  }
});
