PageNavigator.Item = React.createClass({
  propTypes: {
    pages: React.PropTypes.array
  },
  render: function() {
    return (
      <tr>
        <td><a href={"#"+this.props.page.id}>/{this.props.page.attributes.slug}</a></td>
        <td>{this.props.page.attributes.title}</td>
        <td>
          <PageNavigator.StatusLabel status={this.props.page.attributes.status} />
          <PageNavigator.RedirectLabel url={this.props.page.attributes.redirect_url} />
        </td>
      </tr>
    );
  }
});
