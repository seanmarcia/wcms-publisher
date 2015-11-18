PageNavigator.Search = React.createClass({
  propTypes: {
    searchy: React.PropTypes.object
  },
  handleSearchChange: function() {
    this.props.searchy.update('text', this.refs.searchField.value);
  },
  componentDidMount(prevProps) {
    // We transitioned from hidden to shown. Focus the text box.
    this.refs.searchField.focus();
  },
  render: function() {
    return (
      <input
        type="search"
        className="form-control search-field"
        ref="searchField"
        value={this.props.searchy.params.text}
        onChange={this.handleSearchChange}
        placeholder="Search pages"/>
    );
  }
});
