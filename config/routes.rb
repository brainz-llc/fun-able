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
  get "join", to: "games#join_by_code_link", as: :join_game_by_code_link
  post "join", to: "games#join_by_code", as: :join_game_by_code

  # Would You Rather (Que Prefieres)
  resources :would_you_rather, path: 'would-you-rather', only: [:index, :new, :create, :show] do
    collection do
      post :join_by_code
    end

    member do
      get :lobby
      get :join
      post :start
      post :vote
      post :next_round
      post :leave
    end
  end

  # Truth or Dare (Verdad o Reto)
  scope path: 'truth-or-dare', as: 'truth_or_dare' do
    get '/', to: 'truth_or_dare#index', as: :index
    get '/new', to: 'truth_or_dare#new', as: :new
    post '/', to: 'truth_or_dare#create'

    # Join by code
    post '/join-by-code', to: 'truth_or_dare#join_by_code', as: :join_by_code

    scope '/:id' do
      get '/', to: 'truth_or_dare#show', as: :show
      get '/lobby', to: 'truth_or_dare#lobby', as: :lobby
      get '/join', to: 'truth_or_dare#join', as: :join
      get '/play', to: 'truth_or_dare#play', as: :play

      # Game actions
      post '/start', to: 'truth_or_dare#start', as: :start
      post '/choose-truth', to: 'truth_or_dare#choose_truth', as: :choose_truth
      post '/choose-dare', to: 'truth_or_dare#choose_dare', as: :choose_dare
      post '/complete', to: 'truth_or_dare#complete_challenge', as: :complete
      post '/drink', to: 'truth_or_dare#drink', as: :drink
      post '/leave', to: 'truth_or_dare#leave', as: :leave
      post '/kick', to: 'truth_or_dare#kick', as: :kick
      patch '/settings', to: 'truth_or_dare#update_settings', as: :update_settings
    end
  end

  # Most Likely To (Quien es Mas Probable)
  resources :most_likely_to, path: 'most-likely-to', only: [:index, :new, :create, :show] do
    collection do
      post :join_by_code
    end

    member do
      get :lobby
      get :join
      get :play
      post :start
      post :vote
      post :reveal
      post :next_round
      post :leave
    end
  end

  # King's Cup (Copa del Rey)
  scope path: 'kings-cup', as: 'kings_cup' do
    get '/', to: 'kings_cup#index'
    get '/new', to: 'kings_cup#new', as: :new
    post '/', to: 'kings_cup#create'

    # Join by code
    post '/join-by-code', to: 'kings_cup#join_by_code', as: :join_by_code

    scope '/:id' do
      get '/', to: 'kings_cup#show', as: :show
      get '/lobby', to: 'kings_cup#lobby', as: :lobby
      get '/join', to: 'kings_cup#join', as: :join

      # Game actions
      post '/start', to: 'kings_cup#start', as: :start
      post '/draw', to: 'kings_cup#draw_card', as: :draw
      post '/add_rule', to: 'kings_cup#add_rule', as: :add_rule
      post '/set_mate', to: 'kings_cup#set_mate', as: :set_mate
      post '/leave', to: 'kings_cup#leave', as: :leave
      post '/kick', to: 'kings_cup#kick', as: :kick
    end
  end

  # Never Have I Ever (Yo Nunca Nunca)
  scope path: 'never-have-i-ever', as: 'never_have_i_ever' do
    get '/', to: 'never_have_i_ever#index'
    get '/new', to: 'never_have_i_ever#new', as: :new_game
    post '/', to: 'never_have_i_ever#create', as: :games

    # Join by code
    get '/join', to: 'never_have_i_ever#join_by_code_link', as: :join_by_code_link
    post '/join', to: 'never_have_i_ever#join_by_code', as: :join_by_code

    resources :games, controller: 'never_have_i_ever', only: [:show] do
      member do
        get :lobby
        get :join
      end

      resource :actions, controller: 'never_have_i_ever_actions', only: [] do
        post :start
        post :drink
        post :next_card
        post :leave
        post :kick
        patch :update_settings
      end
    end
  end

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
