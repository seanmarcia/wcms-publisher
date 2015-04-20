Rails.application.routes.draw do
  resources :page_editions

  root 'publishers#index'
end
