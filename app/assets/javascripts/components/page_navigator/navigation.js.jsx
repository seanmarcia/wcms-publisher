PageNavigator.Navigation = React.createClass({
  propTypes: {
    selectedPage: React.PropTypes.object,
    onPageSelect: React.PropTypes.func.isRequired,
    searchParams: React.PropTypes.object.isRequired,
  },
  showAllPages: function () {
    return !!this.props.searchParams.all;
  },
  render: function () {
    if (!this.showAllPages()) {
      return (
        <PageNavigator.Breadcrumbs
          selectedPage={this.props.selectedPage}
          onPageSelect={this.props.onPageSelect}/>
      )
    } else {
      return (
        <div></div>
      )
    }
  },
});
