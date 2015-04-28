Rails.application.routes.draw do
  resources :page_editions do
    resources :actors, only: [:create, :destroy]
  end

  root 'publishers#index'
end
