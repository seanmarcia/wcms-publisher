Rails.application.routes.draw do

  resources :calendars, :campus_locations, :important_dates do
    resources :activity_logs, except: [:index, :show, :destroy]
  end

  resources :page_editions do
    resources :actors, only: [:create, :destroy]
    resources :activity_logs, except: [:index, :show, :destroy]
  end

  root 'publishers#index'
end
