var PageNavigator = React.createClass({
  propTypes: {
    url: React.PropTypes.string
  },
  // This sets the default state for the page navigator
  getInitialState: function () {
    return {
      pages: PageEdition.data,
      selectedPage: null,
      searchView: false,
      searchText: ''
    };
  },
  componentDidMount: function() {
    // Initialize all data on first load. This loads in chuncks with most relevant first.
    PageEdition.initialize(this.parentPageId(), function() {
      this.setState({ selectedPage: PageEdition.data[this.parentPageId()] })
    }.bind(this));

    window.onpopstate = function (event) { this.reloadPath(); }.bind(this);

    // Bind keyboard shortcuts
    $(document.body).on('keydown.pageNavigatorShortcuts', this.handleKeyDown);
  },
  componentWillUnMount: function() {
    // unbind keyboard shortcuts
    $(document.body).off('keydown.pageNavigatorShortcuts', this.handleKeyDown);
  },
  reloadPath: function () {
    // Set state as if a page has been selected.
    this.setState({ selectedPage: PageEdition.data[this.parentPageId()] })
    this.closeSearch();
  },
  parentPageId: function () {
    // Get page id from the url Hash.
    // Make sure any falsy value including "" returns null
    return document.location.hash.substring(1) || null
  },
  handleKeyDown: function(event) {
    // console.log("Key Pressed: " + event.keyCode);
    if (event.keyCode >= 65 && event.keyCode <= 90) {
      this.openSearch();
    }
    switch (event.keyCode) {
      case 27: // esc
        this.closeSearch();
        break;
      // case 84: // t
      //   this.openSearch();
      //   break;
    }
  },
  openSearch: function() {
    if (!this.state.searchView) {
      this.setState({searchView: true, searchText: ''});
    }
  },
  closeSearch: function() {
    this.setState({
      searchView: false,
      searchText: ''
    })
  },
  onSearchChange: function(searchText) {
    this.setState({ searchText: searchText });
  },


  render: function () {
    return (
      <div>
        {function(){
          if (this.state.searchView) {
            return <PageNavigator.Search searchText={this.state.searchText} onSearchChange={this.onSearchChange} />
          } else {
            return (
              <div>
                <PageNavigator.Breadcrumbs pages={this.state.pages} selectedPage={this.state.selectedPage} />
                <PageNavigator.ItemPreview page={this.state.selectedPage} />
              </div>
            )
          }
        }.bind(this)()}
        <PageNavigator.Items
          pages={this.state.pages}
          selectedPage={this.state.selectedPage}
          searchText={this.state.searchText}/>
      </div>
    )
  }
});
