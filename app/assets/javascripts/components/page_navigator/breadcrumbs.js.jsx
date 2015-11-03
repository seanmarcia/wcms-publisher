PageNavigator.Breadcrumbs = React.createClass({
  propTypes: {
    pages: React.PropTypes.object,
    selectedPage: React.PropTypes.object,
    onClickBreadcrumb: React.PropTypes.func,
    onClickHome: React.PropTypes.func
  },
  breadcrumbs: function() {
    var crumbs = [];
    var page = this.props.selectedPage;

    // Build breadcrumbs
    while (page) {
      crumbs.push(page);
      page = this.props.pages[page.attributes.parent_page_id];
    }

    return crumbs.reverse().map(function(page) {
      return <PageNavigator.Breadcrumb key={page.id} page={page} onClickBreadcrumb={this.props.onClickBreadcrumb} />
    }.bind(this));
  },
  render: function() {
    return (
      <ol className="breadcrumb">
        <li onClick={this.props.onClickHome}>Home</li>
        {this.breadcrumbs()}
      </ol>
    );
    return <li onClick={this.handleClick}>{this.props.page.attributes.title}</li>
  }
})
