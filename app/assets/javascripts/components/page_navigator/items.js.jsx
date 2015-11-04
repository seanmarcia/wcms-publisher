PageNavigator.Items = React.createClass({
  propTypes: {
    selectedPage: React.PropTypes.object,
    pages: React.PropTypes.object,
    searchText: React.PropTypes.string,
  },
  render: function() {
    var visiblePages = [];
    var rows = [];
    var _this = this;
    var selectedId = this.props.selectedPage ? this.props.selectedPage.id : null;

    var searchStr = _this.props.searchText

    var isFilter = searchStr.match(/ ?is:(\w+) ?/);
    if (isFilter) {
      isFilter = isFilter[1]
      searchStr = searchStr.replace(/ ?is:(\w+) ?/, '')
    }
    var isFilterMatcher = function(status) {
      return !isFilter || (status[0] == isFilter[0]);
    }

    var searchExp = new RegExp(searchStr.replace(" ", ".*"), 'i');

    for (id in this.props.pages) {
      var page = this.props.pages[id]

      if (isFilterMatcher(page.attributes.status) && (page.attributes.slug.match(searchExp) || page.attributes.title.match(searchExp))) {

        if (_this.props.searchText.length > 0 || page.attributes.parent_page_id == selectedId) {
          visiblePages.push(page);
        }
      }
    }

    // sort pages
    visiblePages.sort(function(a,b) {
      return a.attributes.slug.localeCompare(b.attributes.slug);
    });

    visiblePages.forEach(function(page) {
      rows.push(
        <PageNavigator.Item key={page.id} page={page} />
      );
    });

    if (rows.length > 0) {
      return <table className="table table-striped">
        <tbody>{rows}</tbody>
      </table>
    } else {
      return <div><hr/><p>No child pages</p></div>
    }
  }
});
