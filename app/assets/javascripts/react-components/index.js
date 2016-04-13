//= require_self
//= require ./utils
//= require ./stores
//= require ./components
//= require ./routes

// This is the global namespace all the react components will get attached to
// This will help reduce global namespace clutter and conflicts.
App = {
  helpers: {},
  constants: {},
  utils: {
    // These are loaded from ./utils
    Ajax: {},
    EventAPI: {},
    PageEditionAPI: {},
  },
  stores: {
    // These are loaded from ./stores
    EventStore: {},
    NotificationStore: {},
  },
  components: {
    // These are loaded from ./components
  },
};
