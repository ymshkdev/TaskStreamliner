Rails.application.routes.draw do
  devise_for :users
  root 'tasks#index'
  resources :tasks do
   collection do
    get 'day' # /tasks/day URL生成
   end
  end

  resources :teams do
    resources :memberships, only: [:create, :destroy]
  end
  resources :tasks do
    resources :comments, only: [:create, :destroy]
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
