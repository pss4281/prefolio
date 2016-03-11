Rails.application.routes.draw do

  resources :templates do
    resources :processed_images, only: [:create, :update]
    get :jcrop, on: :member
  end

  resource :placeholders, only: [:show]
end
