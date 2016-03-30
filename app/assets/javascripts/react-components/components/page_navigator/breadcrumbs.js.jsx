PageNavigator.Breadcrumb = React.createClass({
  propTypes: {
    selectedPage: React.PropTypes.object,
    onPageSelect: React.PropTypes.func.isRequired,
    page: React.PropTypes.object,
    title: React.PropTypes.string
  },
  isActive: function () {
    return this.props.selectedPage == this.props.page;
  },
  selectPage: function (e) {
    this.props.onPageSelect(this.props.page)
    e.preventDefault();
  },
  render: function () {
    if (this.isActive()) {
      return <li className="active">{this.props.title}</li>;
    } else {
      return <li><a href="#" onClick={this.selectPage}>{this.props.title}</a></li>;
    }
  }
})


PageNavigator.Breadcrumbs = React.createClass({
  propTypes: {
    selectedPage: React.PropTypes.object,
    onPageSelect: React.PropTypes.func.isRequired,
    siteTitle: React.PropTypes.string
  },
  breadcrumbs: function() {
    var crumbs = [];
    var page = this.props.selectedPage;

    // Build breadcrumbs
    while (page) {
      crumbs.push(page);

      // Lookup parent page
      page = PageEdition.data[page.attributes.parent_page_id];
    }

    return crumbs.reverse().map(function(page) {
      return <PageNavigator.Breadcrumb
        key={page.id}
        page={page}
        title={page.attributes.title}
        selectedPage={this.props.selectedPage}
        onPageSelect={this.props.onPageSelect} />
    }.bind(this));
  },
  render: function() {
    // The empty string id attribute is intentional for the Home breadcrumb
    return (
      <ol className="breadcrumb">
        <PageNavigator.Breadcrumb
          title={this.props.siteTitle || 'Home'}
          selectedPage={this.props.selectedPage}
          onPageSelect={this.props.onPageSelect} />

        {this.breadcrumbs()}
      </ol>
    );
  }
})
