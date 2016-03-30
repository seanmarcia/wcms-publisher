(function () {

  App.components.Bootstrap.Checkbox = React.createClass({
    propTypes: {
      name: React.PropTypes.string,
      title: React.PropTypes.string,
      value: React.PropTypes.bool,
    },

    render: function () {
      return <div className="form-group">
        <label>
          <input type="checkbox" name={this.props.name} checked={this.props.value}/>
          &nbsp;{this.props.title || this.props.name}
        </label>
      </div>
    },

  })

})();
