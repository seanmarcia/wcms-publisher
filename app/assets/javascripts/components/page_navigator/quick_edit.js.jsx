(function () {

  var styles = {
    container: {
      position: 'fixed',
      left: 0,
      right: 0,
      top: 0,
      bottom: 0,
      backgroundColor: 'white',
      padding: 20,
      overflow: 'scroll'
    },
    title: {
      fontSize: '2em',
      margin: 0,
      padding: 0
    },
    buttons: {
      float: 'right'
    },
  };

  var RedactorEditor = React.createClass({
    propTypes: {
      text: React.PropTypes.string,
      onChange: React.PropTypes.func
    },
    componentDidMount: function() {
      var onChange = this.props.onChange;

      this.editor = $(this.refs.editor);

      // TODO: this should probably happen through our 'setupRedactor' api. That needs to be
      // made to work with this though.
      this.editor.redactor({
        toolbarFixed: true,
        buttons: ['formatting', 'bold', 'italic', 'underline', 'deleted', 'unorderedlist', 'orderedlist', 'outdent', 'indent', 'image', 'video', 'table', 'link', 'alignment', 'horizontalrule', 'html', 'fullscreen'],
        formatting: ['p', 'blockquote', 'h1', 'h2', 'h3', 'h4', 'h5'],
        replaceDivs: false,
        plugins: ['fullscreen', 'table', 'video'],
        changeCallback: function() {
          onChange(this.code.get());
        }
      });
    },
    componentWillUnmount: function () {
      this.editor.redactor('core.destroy');
    },
    render: function () {
      return <textarea ref="editor" defaultValue={this.props.text} />
    }
  });

  var PresentationDataEditor = React.createClass({
    propTypes: {
      schema: React.PropTypes.any,
      startval: React.PropTypes.object,
      onChange: React.PropTypes.func
    },
    componentDidMount: function () {
      if (this.props.schema && this.props.startval) {
        var schema = this.props.schema;

        // Parse schema if it is a string
        if (typeof(schema) == "string") {
          schema = JSON.parse(schema)
        }

        var editor = new JSONEditor(this.refs.editor, {
          theme: 'bootstrap3',
          iconlib: 'fontawesome4',
          schema: schema,
          startval: this.props.startval
        })

        // Pass form changes up
        if (this.props.onChange) {
          editor.on('change', function() {
            this.props.onChange(editor.getValue())
          }.bind(this))
        }
      }
    },
    render: function () {
      return <div ref="editor"></div>
    }
  });

  PageNavigator.QuickEdit = React.createClass({
    propTypes: {
      page: React.PropTypes.object.isRequired
    },
    getInitialState: function () {
      var attrs = this.props.page.attributes;
      return {
        title: attrs.title,
        body: attrs.body,
        presentation_data: attrs.presentation_data
      }
    },
    componentDidMount: function () {
      $('html, body').css("overflow", "hidden");
    },
    unmount: function () {
      $('html, body').css("overflow", "visible");
      var node = ReactDOM.findDOMNode(this).parentNode;
      ReactDOM.unmountComponentAtNode(node);
      node.parentNode.removeChild(node);
    },
    updateAttribute: function (attr) {
      return function (value) {
        var state = {};
        if (typeof(value) == "object" && value.target) {
          // Handle value as a click event
          state[attr] = value.target.value;
        } else {
          state[attr] = value;
        }
        this.setState(state);
      }.bind(this);
    },
    saveChanges: function () {
      var attrs = this.props.page.attributes;
      attrs.title = this.state.title;
      attrs.body = this.state.body;
      attrs.presentation_data = this.state.presentation_data;
      Notification.new('Saved changes');
      this.unmount();
    },
    render: function () {
      var page = this.props.page;
      return (
        <div style={styles.container}>
          <div className="buttons-spaced" style={styles.buttons}>
            <button className="btn btn-primary" onClick={this.saveChanges}>Save</button>
            <button className="btn btn-default" onClick={this.unmount}>Cancel</button>
          </div>
          <div style={styles.title}>{page.attributes.title}</div>
          <hr />
          <RedactorEditor text={this.state.body} onChange={this.updateAttribute('body')} />
          <PresentationDataEditor
            startval={page.attributes.presentation_data}
            schema={page.attributes.schema}
            onChange={this.updateAttribute('presentation_data')} />
        </div>
      )
    }
  })

})()
