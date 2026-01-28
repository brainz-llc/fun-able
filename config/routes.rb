Rails.application.routes.draw do
  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Root
  root "home#index"

  # Authentication
  resource :session, only: [:new, :create, :destroy] do
    post :create_guest, on: :collection
  end
  resource :registration, only: [:new, :create]

  # Games
  resources :games, only: [:new, :create, :show] do
    member do
      get :lobby
      get :join
    end

    resource :game_actions, only: [], path: "actions" do
      post :start
      post :submit_cards
      post :select_winner
      post :leave
      post :kick
      patch :update_settings
    end
  end

  # Join game by code
  post "join", to: "games#join_by_code", as: :join_game_by_code

  # Decks
  resources :decks do
    member do
      post :publish
      post :unpublish
      post :vote
    end

    collection do
      get :my_decks
    end

    resources :deck_cards, path: "cards" do
      collection do
        post :bulk_create
      end
    end
  end

  # Regions
  resources :regions, only: [:index]

  # API
  namespace :api do
    namespace :v1 do
      resources :memes, only: [] do
        collection do
          get :search
          get :trending
          get :victory
        end
      end
    end
  end

  # Action Cable
  mount ActionCable.server => "/cable"
end
