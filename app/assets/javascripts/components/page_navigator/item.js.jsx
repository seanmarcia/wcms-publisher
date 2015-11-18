PageNavigator.Item = React.createClass({
  propTypes: {
    page: React.PropTypes.object.isRequired
  },
  render: function() {
    return (
      <tr>
        <td><a href={this.props.page.links.self} target="_blank">/{this.props.page.attributes.slug}</a></td>
        <td>{this.props.page.attributes.title}</td>
        <td>
          <PageNavigator.StatusLabel status={this.props.page.attributes.status} />
          <PageNavigator.RedirectLabel url={this.props.page.attributes.redirect_url} />
        </td>
        <td className="last-updated">{moment(this.props.page.attributes.updated_at).fromNow(true)}</td>
        <td><a href={"#"+this.props.page.id}><i className="fa fa-chevron-right"></i></a></td>
      </tr>
    );
  }
});
