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
    this.reloadPath();
    window.onpopstate = function (event) { this.reloadPath(); }.bind(this);

    // Bind keyboard shortcuts
    $(document.body).on('keydown.pageNavigatorShortcuts', this.handleKeyDown);
  },
  componentWillUnMount: function() {
    // unbind keyboard shortcuts
    $(document.body).off('keydown.pageNavigatorShortcuts', this.handleKeyDown);
  },
  reloadPath: function () {
    // Get page id from the url Hash. This way page history works.
    parent_page_id = document.location.hash.substring(1);
    // Make sure any falsy value including "" returns null
    if (!parent_page_id) {
      parent_page_id = null;
      this.setState({ selectedPage: null });
    }

    this.loadPage(parent_page_id);
    this.loadPages(parent_page_id);
  },
  loadPage: function (id) {
    if (id) {
      PageEdition.loadPage(id, function(data) {
        this.setState({
          pages: data,
          selectedPage: (data[id] || null)
        });
      }.bind(this))
    }
  },
  loadPages: function (parent_page_id) {
    PageEdition.loadChildPages(parent_page_id, function(data) {
      this.setState({
        pages: data,
        selectedPage: (data[parent_page_id] || null)
      });
    }.bind(this))
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
    // Load all results for the search
    PageEdition.loadAll(function(data) {
      this.setState({pages: data});
    }.bind(this));

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
  onSelectPage: function(page) {
    this.loadPages(page ? page.id : null);

    this.setState({
      selectedPage: page,
      searchView: false,
      searchText: ''
    });
    this.pushPageState(page);
  },
  onClickBreadcrumb: function(page) {
    this.setState({selectedPage: page});
    this.pushPageState(page);
  },
  onClickHome: function() {
    history.pushState({}, "Page Editions", "#");
    this.reloadPath();
  },
  pushPageState: function (page) {
    history.pushState({}, page.attributes.title, "#"+page.id);
    this.reloadPath();
  },
  onSearchChange: function(searchText) {
    this.setState({
      searchText: searchText
    });
  },
  render: function() {
    return (
      <div>
        {function(){
          if (this.state.searchView) {
            return <PageNavigator.Search
              searchText={this.state.searchText}
              onSearchChange={this.onSearchChange} />
          } else {
            return <div>
              <PageNavigator.Breadcrumbs
                pages={this.state.pages}
                selectedPage={this.state.selectedPage}
                onClickBreadcrumb={this.onClickBreadcrumb}
                onClickHome={this.onClickHome} />
              <PageNavigator.ItemPreview
                page={this.state.selectedPage} />
            </div>
          }
        }.bind(this)()}
        <PageNavigator.Items
          pages={this.state.pages}
          selectedPage={this.state.selectedPage}
          onSelectPage={this.onSelectPage}
          searchText={this.state.searchText}/>
      </div>
    )
  }
});
