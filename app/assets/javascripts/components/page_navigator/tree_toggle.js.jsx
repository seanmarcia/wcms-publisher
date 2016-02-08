PageNavigator.TreeToggle = React.createClass({
  propTypes: {
    searchParams: React.PropTypes.object.isRequired,
    updateSearch: React.PropTypes.func.isRequired
  },
  showAllPages: function () {
    return !!this.props.searchParams.all;
  },
  toggleTreeView: function (e) {
    this.props.updateSearch('all', !this.props.searchParams.all);
    e.target.blur(); // for some reason the link is staying focused after clicking
    e.preventDefault();
  },
  render: function () {
    if (!this.showAllPages()) {
      return (
        <span>
          <a onClick={this.toggleTreeView} href="#">View All</a> | <strong>Tree View</strong>
        </span>
      )
    } else {
      return (
        <span>
          <strong>Viewing all pages</strong> | <a onClick={this.toggleTreeView} href="#">Tree View</a>
        </span>
      )
    }
  },
});
