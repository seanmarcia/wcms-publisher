PageNavigator.Navigation = React.createClass({
  propTypes: {
    selectedPage: React.PropTypes.object,
    onPageSelect: React.PropTypes.func.isRequired,
    searchParams: React.PropTypes.object.isRequired,
    updateSearch: React.PropTypes.func.isRequired,
    pageCount: React.PropTypes.number
  },
  showAllPages: function () {
    return !!this.props.searchParams.all;
  },
  toggleTreeView: function (e) {
    this.props.updateSearch('all', !this.props.searchParams.all);
    e.target.blur(); // for some reason the link is staying focused after clicking
    e.preventDefault();
  },
  newPageLink: function () {
    var selectedId = this.props.selectedPage ? this.props.selectedPage.id : null;
    return "/page_editions/new?site_id=" + PageEdition.siteId + "&parent_page_id=" + (selectedId || "")
  },
  render: function () {
    var newPageButton = <a className="btn btn-default pull-right" href={this.newPageLink()}>New page</a>
    if (!this.showAllPages()) {
      return (
        <div>
          <p>
            <a onClick={this.toggleTreeView} href="#">View All</a> | <strong>Tree View</strong>
            {newPageButton}
          </p>
          <PageNavigator.Breadcrumbs
            selectedPage={this.props.selectedPage}
            onPageSelect={this.props.onPageSelect}/>
        </div>
      )
    } else {
      return (
        <div>
          <p>
            <strong>Viewing all pages</strong> | <a onClick={this.toggleTreeView} href="#">Tree View</a>
            {newPageButton}
          </p>
          <hr/>
        </div>
      )
    }
  },
});
