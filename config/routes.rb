Rails.application.routes.draw do

  root 'books#index'

  get 'books', to: 'books#index'
  get 'books/search', to: 'books#display_search'
  post 'books/search', to: 'books#search'
  post 'books/create', to: 'books#create'
  post 'books/update', to: 'books#status_update'

  devise_for :users, :controllers => {
    :sessions      => "users/sessions",
    :registrations => "users/registrations",
    :passwords     => "users/passwords",
    :omniauth_callbacks => "users/omniauth_callbacks"
  }

  get 'users/setting', to: 'users#display_setting'
  patch 'users/setting', to: 'users#update_setting'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
