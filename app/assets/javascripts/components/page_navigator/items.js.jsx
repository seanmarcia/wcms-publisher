PageNavigator.Items = React.createClass({
  propTypes: {
    selectedPage: React.PropTypes.object,
    searchParams: React.PropTypes.object,
    loadCompleted: React.PropTypes.bool,
    onPageSelect: React.PropTypes.func
  },
  getInitialState: function () {
    return {
      sortBy: 'slug',
      sortAsc: true
    };
  },
  updateSort: function (event) {
    var attribute = event.target.dataset.sort;

    // Toggle if attribute isn't changing, otherwise set to true.
    var newDirection = (this.state.sortBy == attribute) ? !this.state.sortAsc : true;
    this.setState({
      sortBy: attribute,
      sortAsc: newDirection
    });
  },
  headerClass: function(attr) {
    var sortString = '';
    if (attr == this.state.sortBy) {
      if (this.state.sortAsc) {
        sortString += ' asc'
      } else {
        sortString += ' desc'
      }
    }
    return "sortSelect" + sortString;
  },
  selectedId: function () {
    return this.props.selectedPage ? this.props.selectedPage.id : null;
  },
  noResultsText: function () {
    if (this.props.loadCompleted) {
      if (this.props.searchParams.all) {
        return "No pages match your search."
      } else {
        return "No child pages. Search all pages for more results."
      }
    } else {
      return "Loading pages..."
    }
  },
  visiblePages: function () {
    // sort pages
    var sortAscending = this.state.sortAsc;
    var sortBy = this.state.sortBy;

    return PageEdition.search(this.props.searchParams, this.selectedId()).sort(function(a,b) {
      if (sortAscending) {
        return a.attributes[sortBy].localeCompare(b.attributes[sortBy]);
      } else {
        return b.attributes[sortBy].localeCompare(a.attributes[sortBy]);
      }
    });
  },
  render: function() {
    var pages = this.visiblePages();

    if (pages.length > 0) {
      return <div>
        <table className="table table-striped">
          <thead>
            <tr>
              <th>
                <span className={this.headerClass('title')} onClick={this.updateSort} data-sort="title">Title</span>
                <span style={{padding: "0 15px"}}>|</span>
                <span className={this.headerClass('slug')} onClick={this.updateSort} data-sort="slug">Slug</span>
              </th>
              <th><span className={this.headerClass('status')} onClick={this.updateSort} data-sort="status">Status</span></th>
              <th><span className={this.headerClass('updated_at')} onClick={this.updateSort} data-sort="updated_at">Updated</span></th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            {pages.map(function(page) {
              return <PageNavigator.Item key={page.id} page={page} onPageSelect={this.props.onPageSelect} />
            }.bind(this))}
          </tbody>
        </table>
      </div>
    } else {
      return <div>
        <p>{this.noResultsText()}</p>
      </div>
    }
  }
});
