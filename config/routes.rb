Wcms::Application.routes.draw do

  resources :menus do
    resources :activity_logs, except: [:index, :show, :destroy]
  end

  resources :calendars, :campus_locations, :important_dates do
    resources :activity_logs, except: [:index, :show, :destroy]
  end

  resources :page_editions do
    resources :attachments
    resources :actors, only: [:create, :destroy]
    resources :activity_logs, except: [:index, :show, :destroy]
  end
  resources :service_links do
    resources :activity_logs, except: [:index, :show, :destroy]
  end

  root 'publishers#index'
end
