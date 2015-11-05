PageNavigator.Items = React.createClass({
  propTypes: {
    selectedPage: React.PropTypes.object,
    searchy: React.PropTypes.object,
  },
  render: function() {
    var visiblePages = [];
    var selectedId = this.props.selectedPage ? this.props.selectedPage.id : null;

    if (this.props.searchy.active()) {
      visiblePages = PageEdition.search(this.props.searchy.params);
    } else {
      visiblePages = PageEdition.childPages(selectedId);
    }

    // sort pages
    visiblePages.sort(function(a,b) {
      return a.attributes.slug.localeCompare(b.attributes.slug);
    });

    var rows = [];
    visiblePages.forEach(function(page) {
      rows.push(
        <PageNavigator.Item key={page.id} page={page} />
      );
    });

    if (rows.length > 0) {
      return <table className="table table-striped">
        <thead>
          <tr>
            <th>Slug</th>
            <th>Title</th>
            <th>Status</th>
          </tr>
        </thead>
        <tbody>{rows}</tbody>
      </table>
    } else {
      return <div><hr/><p>No child pages</p></div>
    }
  }
});
