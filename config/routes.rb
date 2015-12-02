Wcms::Application.routes.draw do

  namespace :api, defaults: {format: :json} do
    resources :page_editions
  end

  resources :menus, :calendars, :campus_locations, :important_dates, :service_links do
  end

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

  root 'publishers#index'
end
