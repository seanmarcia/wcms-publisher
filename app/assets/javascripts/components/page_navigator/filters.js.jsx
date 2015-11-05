PageNavigator.Filter = React.createClass({
  propTypes: {
    // I'm using 'for' because 'key' is a reserved name
    for: React.PropTypes.string,
    val: React.PropTypes.string,
    searchy: React.PropTypes.object
  },
  toggle: function (e) {
    if (this.props.searchy.params[this.props.for] == this.props.val)
      this.props.searchy.update(this.props.for, null);
    else
      this.props.searchy.update(this.props.for, this.props.val);

    e.preventDefault();
    return false;
  },
  linkClass: function () {
    return (this.props.searchy.params[this.props.for] == this.props.val) ? "active" : '';
  },
  render: function() {
    return <li className={this.linkClass()}><a onClick={this.toggle} href="#">{this.props.title}</a></li>
  }
});

PageNavigator.Filters = React.createClass({
  propTypes: {
    searchy: React.PropTypes.object
  },
  render: function() {
    return (
      <ul className="nav nav-list well">
        <PageNavigator.Filter searchy={this.props.searchy} title="All Pages" for="all" val="true" />
        <li className="nav-header">Status</li>
        <PageNavigator.Filter searchy={this.props.searchy} title="Draft" for="status" val="draft" />
        <PageNavigator.Filter searchy={this.props.searchy} title="Up for Review" for="status" val="request_review" />
        <PageNavigator.Filter searchy={this.props.searchy} title="Published" for="status" val="published" />
        <PageNavigator.Filter searchy={this.props.searchy} title="Archived" for="status" val="archived" />
        <li className="nav-header">Redirect</li>
        <PageNavigator.Filter searchy={this.props.searchy} title="Is Redirect" for="redirect" val="true" />
      </ul>
    );
  }
});
