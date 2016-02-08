PageNavigator.Item = React.createClass({
  propTypes: {
    page: React.PropTypes.object.isRequired,
    onPageSelect: React.PropTypes.func.isRequired
  },
  selectPage: function (e) {
    this.props.onPageSelect(this.props.page)
    e.preventDefault();
  },
  openQuickEdit: function () {
    var node = document.createElement("div");
    document.body.appendChild(node);
    ReactDOM.render(<PageNavigator.QuickEdit page={this.props.page} />, node);
  },
  render: function() {
    var page = this.props.page;

    return (
      <tr>
        <td>
          <strong><a href={page.links.self}>{page.attributes.title}</a></strong>
          <br/>
          <span className="text-muted">/{page.attributes.slug}</span>
          <button className="btn btn-default pull-right" onClick={this.openQuickEdit}>Quick Edit</button>
        </td>
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
