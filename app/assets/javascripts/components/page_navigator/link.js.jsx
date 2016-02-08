PageNavigator.Link = React.createClass({
  propTypes: {
    title: React.PropTypes.string,
    link: React.PropTypes.string,
    handleClick: React.PropTypes.func,
    clickValue: React.PropTypes.any,
  },
  handleClick: function (e) {
    if (this.props.handleClick) {
      this.props.handleClick(this.props.clickValue);
      e.preventDefault();
      return false;
    }
  },
  render: function () {
    return <a href={this.props.link || "#"} onClick={this.handleClick}>{this.props.title}</a>
  }
})
