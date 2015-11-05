PageNavigator.ItemPreview = React.createClass({
  propTypes: {
    page: React.PropTypes.object
  },
  render: function() {
    if (this.props.page) {
      return (
        <div className="pagePreview well">
          <p>
            <a className="btn btn-primary pull-right" href={this.props.page.links.self}>Edit Page</a>
            <a className="btn btn-default pull-right" href={this.props.page.attributes.preview_url}>Preview Page</a>
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
