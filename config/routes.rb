Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "dashboard#index"

  resources :cards, only: [:index, :destroy] do
    collection do
      get  :import
      post :import, action: :do_import
      post :reset
    end
  end

  get  "study"          => "study#show"
  post "study/:id/grade" => "study#grade", as: :grade_card

  # Serve uploaded photos
  get "photos/:filename" => "photos#show", as: :photo, constraints: { filename: /[^\/]+/ }
end
