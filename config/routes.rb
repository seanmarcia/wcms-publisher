Wcms::Application.routes.draw do
  resources :menus, :calendars, :campus_locations, :important_dates, :service_links

  resources :page_editions do
    resources :audience_collections, only: [:update]
    resources :attachments
    resources :actors, only: [:create, :destroy]
    post :create_tag, on: :member
    get :view_topics, on: :collection
  end

  resources :sites do
    resources :site_categories, only: [:create, :update, :destroy]
    resources :feature_locations, only: [:create, :update, :destroy]
    resources :actors
  end

  resources :media do
    resources :media_resources, only: [:create, :destroy]
  end

  root 'publishers#index'
end
