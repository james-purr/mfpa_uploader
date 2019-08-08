Rails.application.routes.draw do
  mount Lockup::Engine, at: '/lockup'
  resources :uploads
  resources :bookings
  match 'booking-by-reference/:reference', to: 'bookings#reference', via: [:get]
  match 'update-booking-status/:id/:status', to: 'bookings#update_booking_status', via: [:post]

  match 'search', to: 'uploads#search', via: [:post], as: :booking_search, :defaults => { :format => :json }
  match 'get-missing-images/:id', to: 'uploads#get_missing_images', via: [:get], as: :missing_images, :defaults => { :format => :json }
  match 'upload_to_server', to: 'uploads#upload_to_server', via: [:post], as: :upload_to_server, :defaults => { :format => :json }
  match 'search-bookings', to: 'uploads#search_bookings', via: [:get], as: :search_bookings


  root "uploads#search_bookings"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
