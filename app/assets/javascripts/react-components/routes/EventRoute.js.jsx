$( document ).ready(function() {
  // Imports
  var Router = ReactRouter.Router;
  var Route = ReactRouter.Route;
  var render = ReactDOM.render;

  render((
    <Router onUpdate={function() {window.scrollTo(0, 0)} }>
      <Route path="/" component={App.components.Event.list} />
      <Route path="/:id" component={App.components.Event.show}/>
    </Router>
  ), document.getElementById('event-react-component'))
});
