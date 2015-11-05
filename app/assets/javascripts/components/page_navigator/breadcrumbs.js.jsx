PageNavigator.Breadcrumbs = React.createClass({
  propTypes: {
    selectedPage: React.PropTypes.object,
  },
  breadcrumbs: function() {
    var crumbs = [];
    var page = this.props.selectedPage;

    // Build breadcrumbs
    while (page) {
      crumbs.push(page);
      page = PageEdition.data[page.attributes.parent_page_id];
    }

    return crumbs.reverse().map(function(page) {
      return <PageNavigator.Breadcrumb key={page.id} id={page.id} title={page.attributes.title} />
    });
  },
  render: function() {
    // The empty string id attribute is intentional for the Home breadcrumb
    return (
      <ol className="breadcrumb">
        <PageNavigator.Breadcrumb id="" title="Home" />
        {this.breadcrumbs()}
      </ol>
    );
  }
})
