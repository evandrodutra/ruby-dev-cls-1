Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  resources :directories, only: [ :create, :index, :show, :destroy ] do
    resources :files, only: [ :create, :index, :destroy ]
  end

  root "directories#index"
end
