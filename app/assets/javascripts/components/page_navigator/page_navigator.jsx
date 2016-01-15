var PageNavigator = React.createClass({
  propTypes: {
    sites: React.PropTypes.array
  },
  // This sets the default state for the page navigator
  getInitialState: function () {
    defaults = {
      selectedPage: null,
      selectedSite: null,
      pageCount: 0,
      loadCompleted: false,
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
    this.setState({loadCompleted: false})
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
  updateSite: function (newSite) {
    this.setState({
      selectedSite: newSite
    }, function () {
      // Callback to run after state changes
      this.loadPages();
      this.saveState();
    }.bind(this));
  },
  siteTitle: function (siteId) {
    var site = this.props.sites.find(function(site) {
      return site.id === siteId;
    });
    if (site) {
      return site.title;
    }
  },
  handleSearchChange: function () {
    this.updateSearch('text', this.refs.searchField.value);
  },
  newPageLink: function () {
    var selectedId = this.state.selectedPage ? this.state.selectedPage.id : null;
    return "/page_editions/new?site_id=" + PageEdition.siteId + "&parent_page_id=" + (selectedId || "")
  },
  render: function () {
    if (!this.state.selectedSite) {
      return (
        <div>
          <h3>Select Site</h3>
          <table className="table table-striped">
            <tbody>
              {this.props.sites.map(function(site) {
                return <tr key={site.id}>
                  <td>
                    <PageNavigator.Link title={site.title} handleClick={this.updateSite} clickValue={site} />
                  </td>
                  <td>{site.url}</td>
                </tr>
              }.bind(this))}
            </tbody>
          </table>
        </div>
      )
    } else {
      return (
        <div id="PageNavigator">
          <div>
            <div className="dropdown">
              <h3 className="site-select" data-toggle="dropdown">
                {this.state.selectedSite.title} <i className="fa fa-caret-down"></i>
              </h3>
              <ul className="dropdown-menu">
                {this.props.sites.map(function(site) {
                  return <li key={site.id}>
                    <PageNavigator.Link title={site.title} handleClick={this.updateSite} clickValue={site} />
                  </li>
                }.bind(this))}
              </ul>
            </div>
          </div>
          <hr/>
          <div className="row">
            <div className="col-sm-6 bottom-margin">
              <PageNavigator.TreeToggle
                searchParams={this.state.searchParams}
                updateSearch={this.updateSearch} />
            </div>
            <div className="col-sm-6 bottom-margin">
              <a className="btn btn-default pull-right" href={this.newPageLink()}>New page</a>
              <div className="input-group input-group-search">
                <input type="search" ref="searchField" placeholder="Search pages" className="form-control search-field"
                  value={this.state.searchParams.text}
                  onChange={this.handleSearchChange} />
                <span className="input-group-btn dropdown">
                  <button className="btn btn-default" type="button" data-toggle="dropdown">
                    <i className="fa fa-filter"></i>
                  </button>
                  <div className="dropdown-menu pull-right">
                    <PageNavigator.Filters
                      searchParams={this.state.searchParams}
                      updateSearch={this.updateSearch} />
                  </div>
                </span>
              </div>
            </div>
          </div>
          <div>
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
  }
});
