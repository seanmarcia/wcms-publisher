PageNavigator.ItemPreview = React.createClass({
  propTypes: {
    page: React.PropTypes.object
  },
  openQuickEdit: function () {
    var node = document.createElement("div");
    document.body.appendChild(node);
    ReactDOM.render(<PageNavigator.QuickEdit page={this.props.page} />, node);
  },
  render: function() {
    if (this.props.page) {
      return (
        <div className="pagePreview well">
          <p>
            <a className="btn btn-primary pull-right" href={this.props.page.links.self}>Edit Page</a>
            <a className="btn btn-default pull-right" href={this.props.page.attributes.preview_url}>Preview Page</a>
            <button className="btn btn-default pull-right" onClick={this.openQuickEdit}>Quick Edit</button>
            <strong>/{this.props.page.attributes.slug}</strong><br/>
            <PageNavigator.StatusLabel status={this.props.page.attributes.status} />
            <PageNavigator.RedirectLabel url={this.props.page.attributes.redirect_url} />
            <span className="clearfix"></span>
          </p>
        </div>
      );
    } else {
      return null;
    }
  }
})
