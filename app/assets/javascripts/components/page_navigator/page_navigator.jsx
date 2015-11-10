var PageNavigator = React.createClass({
  propTypes: {
    siteTitle: React.PropTypes.string
  },
  // This sets the default state for the page navigator
  getInitialState: function () {
    return {
      selectedPage: null,
      searchParams: {}
    };
  },
  componentDidMount: function() {
    // Initialize all data on first load. This loads in chuncks with most relevant first.
    PageEdition.initialize(this.selectedPageId(), function() {
      this.setState({ selectedPage: PageEdition.data[this.selectedPageId()] })
    }.bind(this));

    window.onpopstate = function (event) { this.reloadPath(); }.bind(this);
  },
  reloadPath: function () {
    // Set state as if a page has been selected.
    this.setState({ selectedPage: PageEdition.data[this.selectedPageId()] })
    this.clearSearch();
  },
  selectedPageId: function () {
    // Get page id from the url Hash.
    // Make sure any falsy value including "" returns null
    return document.location.hash.substring(1) || null
  },

  updateSearch: function(key, value) {
    var newParams = this.state.searchParams;

    if (value == null)
      delete newParams[key]
    else
      newParams[key] = value

    this.setState({ searchParams: newParams });
    console.log(newParams);
  },
  clearSearch: function() {
    this.setState({
      searchParams: {}
    })
  },
  // Package search stuff together so I don't have to pass them down the tree seperately
  searchy: function() {
    return {
      params: this.state.searchParams,
      update: this.updateSearch,
      clear: this.clearSearch,
    }
  },
  showAllPages: function () {
    return !!this.state.searchParams.all;
  },
  navigation: function () {
    if (!this.showAllPages()) {
      return (
        <div>
          <PageNavigator.Breadcrumbs selectedPage={this.state.selectedPage} siteTitle={this.props.siteTitle} />
          <PageNavigator.ItemPreview page={this.state.selectedPage} />
        </div>
      )
    }
  },
  render: function () {
    return (
      <div className="row">
        <div className="col-md-3">
          <PageNavigator.Search searchy={this.searchy()} />
          <br/>
          <PageNavigator.Filters searchy={this.searchy()} />
        </div>
        <div className="col-md-9">
          {this.navigation()}
          <PageNavigator.Items
            selectedPage={this.state.selectedPage}
            searchy={this.searchy()} />
        </div>
      </div>
    )
  }
});
