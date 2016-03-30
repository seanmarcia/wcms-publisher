(function () {
  // Imports
  EventStore = App.stores.EventStore;
  Link = ReactRouter.Link;


  function getStateFromStores() {
    return {
      events: EventStore.getAll(),
    }
  }

  App.components.Event.list = React.createClass({
    getInitialState: function () {
      return getStateFromStores();
    },

    componentDidMount: function () {
      EventStore.addChangeListener(this._onChange);

      EventStore.loadFromAPI({future: true});
    },

    componentWillUnmount: function () {
      EventStore.removeChangeListener(this._onChange);
    },

    _onChange: function () {
      this.setState(getStateFromStores());
    },

    selectEvent: function (event) {

    },

    render: function() {
      _this = this;
      var eventRows = this.state.events.map(function (event) {
        return <tr key={event.id}>
          <td onclick={function() {_this.selectEvent(event)}}>
            <Link to={`/${event.id}`}>{event.attributes.title}</Link></td>
          <td>{moment(event.attributes.start_date).format("ddd, MMM D, YYYY, h:mm a")}</td>
        </tr>
      })

      return <div>
        <table className="table">
          <thead>
            <tr>
              <th>Title</th>
              <th>Starts</th>
            </tr>
          </thead>
          <tbody>
            {eventRows}
          </tbody>
        </table>
      </div>
    }
  });

})();
