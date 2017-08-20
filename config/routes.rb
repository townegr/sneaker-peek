Rails.application.routes.draw do
  get '/auth/:provider/callback', to: 'sessions#create'

  resources :twitter_entities

  root to: "twitter_entities#index"
end
