//= require ./page_navigator
//= require ./search
//= require ./filters
//= require ./items
//= require ./item
//= require ./item_preview
//= require ./breadcrumbs
//= require ./breadcrumb
//= require ./labels

$(document).ready(function() {
  var PageNavigatorContainer = document.getElementById('PageNavigator');

  if (PageNavigatorContainer) {
    ReactDOM.render(
      <PageNavigator siteTitle={PageNavigatorContainer.dataset.siteTitle} />,
      PageNavigatorContainer
    );
  }
})
