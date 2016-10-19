Wcms::Application.routes.draw do
  resources :menus, :campus_locations

  resources :calendars do
    resources :actors, only: [:create, :destroy]
  end

  resources :articles do
    resources :gallery_photos do
      put :sort, on: :collection
    end
    get :search, on: :collection
    post :update_from_ws, on: :collection
  end

  resources :service_links do
    resources :audience_collections, only: [:update]
  end

  resources :users, only: [:index] do
    get :impersonate, on: :member
    get :stop_impersonating, on: :collection
  end

  resources :important_dates do
    resources :audience_collections, only: [:update]
  end

  resources :page_editions do
    resources :audience_collections, only: [:update]
    resources :attachments
    resources :actors, only: [:create, :destroy]
    post :create_tag, on: :member
    get :view_topics, on: :collection
  end

  resources :presentation_data_templates

  resources :events do
    resources :links
    resources :tickets, except: [:index, :show]
    resources :actors, only: [:create, :destroy]
    get :duplicate, on: :member
    post :update_from_ws, on: :collection
  end
  resources :event_collections

  resources :sites do
    resources :site_categories, only: [:create, :update, :destroy]
    resources :feature_locations, only: [:create, :update, :destroy]
    resources :actors
  end

  resources :media do
    resources :media_resources, only: [:create, :destroy]
  end

  resources :photo_galleries do
    resources :gallery_photos do
      put :sort, on: :collection
    end
  end

  resources :relationships, only: [:create, :destroy]

  root 'publishers#index'
end
