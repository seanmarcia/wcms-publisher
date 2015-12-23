PageNavigator.Filter = React.createClass({
  propTypes: {
    // I'm using 'for' because 'key' is a reserved name
    for: React.PropTypes.string.isRequired,
    val: React.PropTypes.string.isRequired,
    search: React.PropTypes.object.isRequired
  },
  toggle: function (e) {
    if (this.props.search.params[this.props.for] == this.props.val)
      this.props.search.update(this.props.for, null);
    else
      this.props.search.update(this.props.for, this.props.val);

    e.preventDefault();
    return false;
  },
  linkClass: function () {
    return (this.props.search.params[this.props.for] == this.props.val) ? "active" : '';
  },
  render: function() {
    return <li className={this.linkClass()}><a onClick={this.toggle} href="#">{this.props.title}</a></li>
  }
});

PageNavigator.Filters = React.createClass({
  propTypes: {
    searchParams: React.PropTypes.object.isRequired,
    updateSearch: React.PropTypes.func.isRequired
  },
  // Package search stuff together so I don't have to pass them down the tree seperately
  search: function() {
    return {
      params: this.props.searchParams,
      update: this.props.updateSearch,
    }
  },
  render: function() {
    return (
      <ul className="nav nav-list well">
        <li className="nav-header">Status</li>
        <PageNavigator.Filter search={this.search()} title="Draft" for="status" val="draft" />
        <PageNavigator.Filter search={this.search()} title="Up for Review" for="status" val="request_review" />
        <PageNavigator.Filter search={this.search()} title="Published" for="status" val="published" />
        <PageNavigator.Filter search={this.search()} title="Archived" for="status" val="archived" />
        <li className="nav-header">Redirect</li>
        <PageNavigator.Filter search={this.search()} title="Is Redirect" for="redirect" val="true" />
      </ul>
    );
  }
});
