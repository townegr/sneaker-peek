Rails.application.routes.draw do
  get '/auth/twitter', as: 'auth_twitter'
  get '/auth/:provider/callback', to: 'sessions#create'

  resources :twitter_entities

  root to: "twitter_entities#index"
end
