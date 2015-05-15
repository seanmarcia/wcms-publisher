Rails.application.routes.draw do

  resources :calendars
  resources :campus_locations
  resources :important_dates
  resources :page_editions do
    resources :actors, only: [:create, :destroy]
  end

  root 'publishers#index'
end
