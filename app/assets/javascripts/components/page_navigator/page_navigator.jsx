var PageNavigator = React.createClass({
  propTypes: {
    sites: React.PropTypes.array
  },
  // This sets the default state for the page navigator
  getInitialState: function () {
    defaults = {
      selectedPage: null,
      selectedSite: this.props.sites[0].id,
      pageCount: 0,
      searchParams: {
        all: true
      }
    };

    store = sessionStorage.getItem('PageNavigator.savedState');
    if (store)
      return $.extend(defaults, JSON.parse(store));
    else
      return defaults;
  },
  saveState: function () {
    sessionStorage.setItem('PageNavigator.savedState', JSON.stringify({
      selectedPage: this.state.selectedPage,
      selectedSite: this.state.selectedSite,
      searchParams: this.state.searchParams
    }));
  },
  loadPages: function () {
    // Initialize all data on first load. This loads in chuncks with most relevant first.
    PageEdition.initialize(this.state.selectedSite, this.state.selectedPage, function(loadCompleted) {
      this.setState({
        pageCount: PageEdition.count(),
        loadCompleted: !!loadCompleted
      })
    }.bind(this));
  },
  componentDidMount: function() {
    this.loadPages();
    window.onpopstate = function (event) { this.onPageSelect(); }.bind(this);
  },
  onPageSelect: function (page) {
    // Set state as if a page has been selected.
    this.setState({
      selectedPage: page,
      searchParams: {
        all: false
      }
    }, this.saveState);
  },
  selectedPageId: function () {
    // Get page id from the url Hash.
    // Make sure any falsy value including "" returns null
    return document.location.hash.substring(1) || null
  },

  updateSearch: function(key, value) {
    var newParams = this.state.searchParams;

    if (value == null || value == false)
      delete newParams[key]
    else
      newParams[key] = value

    this.setState({ searchParams: newParams }, this.saveState);
  },
  updateSite: function () {
    this.setState({
      selectedSite: this.refs.siteSelect.value
    }, function () {
      // Callback to run after state changes
      this.loadPages();
      this.saveState();
    }.bind(this));
  },
  handleSearchChange: function () {
    this.updateSearch('text', this.refs.searchField.value);
  },
  render: function () {
    return (
      <div id="PageNavigator" className="row">
        <div className="col-md-3">
          <select className="form-control" ref="siteSelect" value={this.state.selectedSite} onChange={this.updateSite}>
            {this.props.sites.map(function(site) {
              return <option key={site.id} value={site.id}>{site.title}</option>
            })}
          </select>
          <br/>
          <input type="search" ref="searchField" placeholder="Search pages" className="form-control search-field"
            value={this.state.searchParams.text}
            onChange={this.handleSearchChange} />
          <br/>
          <PageNavigator.Filters
            searchParams={this.state.searchParams}
            updateSearch={this.updateSearch} />
        </div>
        <div className="col-md-9">
          <PageNavigator.Navigation
            selectedPage={this.state.selectedPage}
            searchParams={this.state.searchParams}
            onPageSelect={this.onPageSelect}
            updateSearch={this.updateSearch}
            pageCount={this.state.pageCount} />
          <PageNavigator.Items
            selectedPage={this.state.selectedPage}
            searchParams={this.state.searchParams}
            loadCompleted={this.state.loadCompleted}
            onPageSelect={this.onPageSelect} />
        </div>
      </div>
    )
  }
});
