PageNavigator.Search = React.createClass({
  propTypes: {
    searchText: React.PropTypes.string,
    onSearchChange: React.PropTypes.func
  },
  handleSearchChange: function() {
    this.props.onSearchChange(
      this.refs.searchField.value
    );
  },
  componentDidMount(prevProps) {
    // We transitioned from hidden to shown. Focus the text box.
    this.refs.searchField.focus();
  },
  render: function() {
    return (
      <input
        type="search"
        className="search-field"
        ref="searchField"
        value={this.props.searchText}
        onChange={this.handleSearchChange}
        placeholder="Search all pages"/>
    );
  }
});
