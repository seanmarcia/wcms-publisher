(function () {
  EventStore = App.stores.EventStore;
  Input = App.components.Bootstrap.Input;
  Checkbox = App.components.Bootstrap.Checkbox;


  function getStateFromStores(id) {
    return {
      event: EventStore.get(id),
    }
  }

  App.components.Event.show = React.createClass({
    getInitialState: function () {
      state = getStateFromStores(this.props.params.id);

      // userChanges will keep track of fields the user has changed.
      state.userChanges = {};
      return state;
    },

    componentDidMount: function () {
      EventStore.addChangeListener(this._onChange);

      EventStore.loadFromAPI({id: this.props.params.id, limit: 1, show_details: true});
    },

    componentWillUnmount: function () {
      EventStore.removeChangeListener(this._onChange);
    },

    _onChange: function () {
      this.setState(getStateFromStores(this.props.params.id));
    },

    userEdit: function (name, value) {
      changes = this.state.userChanges;
      changes[name] = value;
      this.setState({userChanges: changes});
    },

    fieldValue: function (name) {
      return Object.assign({}, this.state.event.attributes, this.state.userChanges)[name];
    },

    save: function () {
      EventStore.updateEvent(this.props.params.id, this.state.userChanges);
    },

    render: function() {
      var event = this.state.event;

      if (event) {

        return <div>
          <Input name="title" onChange={this.userEdit} value={this.fieldValue('title')} />
          <Input name="slug" onChange={this.userEdit} value={this.fieldValue('slug')} />
          <Input name="subtitle" onChange={this.userEdit} value={this.fieldValue('subtitle')} />
          <Input name="location_type" onChange={this.userEdit} value={this.fieldValue('location_type')} />
          <Input name="custom_campus_location" onChange={this.userEdit} value={this.fieldValue('custom_campus_location')} />
          <Input name="start_date" onChange={this.userEdit} value={this.fieldValue('start_date')} />
          <Input name="end_date" onChange={this.userEdit} value={this.fieldValue('end_date')} />
          <Input name="categories" onChange={this.userEdit} value={this.fieldValue('categories')} />
          <Input name="contact_name" onChange={this.userEdit} value={this.fieldValue('contact_name')} />
          <Input name="contact_email" onChange={this.userEdit} value={this.fieldValue('contact_email')} />
          <Input name="contact_phone" onChange={this.userEdit} value={this.fieldValue('contact_phone')} />
          <Checkbox name="paid" onChange={this.userEdit} value={this.fieldValue('paid')} />
          <Checkbox name="featured" onChange={this.userEdit} value={this.fieldValue('featured')} />
          <Input name="admission_info" onChange={this.userEdit} value={this.fieldValue('admission_info')} />
          {/*<Input name="audience" onChange={this.userEdit} value={this.fieldValue('audience')} />*/}
          <Input name="map_url" onChange={this.userEdit} value={this.fieldValue('map_url')} />
          <Input name="registration_info" onChange={this.userEdit} value={this.fieldValue('registration_info')} />
          <Input name="sponsor" onChange={this.userEdit} value={this.fieldValue('sponsor')} />
          <Input name="sponsor_site" onChange={this.userEdit} value={this.fieldValue('sponsor_site')} />
          <Input name="teaser" onChange={this.userEdit} value={this.fieldValue('teaser')} />

          <div>
            <button className="btn btn-biola" onClick={this.save}>Save</button>
          </div>

        </div>
      } else {
        return <div>Event not found</div>
      }
    }
  });

})();
