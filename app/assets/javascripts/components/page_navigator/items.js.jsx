PageNavigator.Items = React.createClass({
  propTypes: {
    selectedPage: React.PropTypes.object,
    searchy: React.PropTypes.object,
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
  newPageLink: function () {
    return "/page_editions/new?site_id=" + PageEdition.siteId + "&parent_page_id=" + (this.selectedId() || "")
  },
  render: function() {
    var visiblePages = PageEdition.search(this.props.searchy.params, this.selectedId());

    // sort pages
    var sortAscending = this.state.sortAsc;
    var sortBy = this.state.sortBy;
    visiblePages.sort(function(a,b) {
      if (sortAscending) {
        return a.attributes[sortBy].localeCompare(b.attributes[sortBy]);
      } else {
        return b.attributes[sortBy].localeCompare(a.attributes[sortBy]);
      }
    });

    var rows = [];
    visiblePages.forEach(function(page) {
      rows.push(
        <PageNavigator.Item key={page.id} page={page} />
      );
    });
    var newPageButton = <a className="btn btn-default" href={this.newPageLink()}>New page</a>

    if (rows.length > 0) {
      return <div>
        <table className="table table-striped">
          <thead>
            <tr>
              <th><span className={this.headerClass('slug')} onClick={this.updateSort} data-sort="slug">Slug</span></th>
              <th><span className={this.headerClass('title')} onClick={this.updateSort} data-sort="title">Title</span></th>
              <th><span className={this.headerClass('status')} onClick={this.updateSort} data-sort="status">Status</span></th>
              <th><span className={this.headerClass('updated_at')} onClick={this.updateSort} data-sort="updated_at">Updated</span></th>
            </tr>
          </thead>
          <tbody>{rows}</tbody>
        </table>
        {newPageButton}
      </div>
    } else {
      return <div><hr/>
        <p>No child pages</p>
        <p>{newPageButton}</p>
      </div>
    }
  }
});
