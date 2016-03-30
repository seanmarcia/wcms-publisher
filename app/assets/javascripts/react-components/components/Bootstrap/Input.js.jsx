(function () {

  App.components.Bootstrap.Input = React.createClass({
    propTypes: {
      type: React.PropTypes.string,
      name: React.PropTypes.string,
      title: React.PropTypes.string,
      value: React.PropTypes.string,
      onChange: React.PropTypes.func,
    },

    handleChange: function (e) {
      this.props.onChange(this.props.name, e.target.value)
    },

    render: function () {
      return <div className="form-group">
        <label>{this.props.title || this.props.name}</label>
        <input
          type={this.props.type || 'text'}
          className="form-control"
          name={this.props.name}
          value={this.props.value}
          onChange={this.handleChange}
          />
      </div>
    },

  })

})();
