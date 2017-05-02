Rails.application.routes.draw do
  get 'books', to: 'books#index'
  get 'books/search', to: 'books#display_search'
  post 'books/search', to: 'books#search'
  post 'books/create', to: 'books#create'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
