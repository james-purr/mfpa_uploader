Rails.application.routes.draw do
  resources :uploads
  match 'search', to: 'uploads#search', via: [:post], as: :booking_search
  root "uploads#index"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
