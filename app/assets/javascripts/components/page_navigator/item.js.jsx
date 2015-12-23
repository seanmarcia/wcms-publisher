PageNavigator.Item = React.createClass({
  propTypes: {
    page: React.PropTypes.object.isRequired,
    onPageSelect: React.PropTypes.func.isRequired
  },
  selectPage: function (e) {
    this.props.onPageSelect(this.props.page)
    e.preventDefault();
  },
  render: function() {
    var page = this.props.page;

    return (
      <tr>
        <td><a href={page.links.self}>/{page.attributes.slug}</a></td>
        <td>{page.attributes.title}</td>
        <td>
          <PageNavigator.StatusLabel status={page.attributes.status} />
          <PageNavigator.RedirectLabel url={page.attributes.redirect_url} />
        </td>
        <td className="last-updated">{moment(page.attributes.updated_at).fromNow(true)}</td>
        <td><a href="#" onClick={this.selectPage}><i className="fa fa-chevron-right"></i></a></td>
      </tr>
    );
  }
});
