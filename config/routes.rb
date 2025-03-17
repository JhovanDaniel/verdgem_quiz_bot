Rails.application.routes.draw do
  
  get 'quiz/start'
  get 'quiz/show'
  get 'quiz/evaluate_answer'
  get 'quiz/result'
  get 'questions/show'
  get 'topics/index'
  get 'topics/show'
  get 'subjects/index'
  get 'subjects/show'
  
  resources :subjects do
    resources :topics, only: [:index, :new, :create]
  end
  
  resources :topics, except: [:index] do
    resources :questions, only: [:new, :create]
  end
  
  resources :questions, except: [:index, :new, :create]
  
  devise_for :users, controllers: {
    registrations: 'users/registrations'
  }
  
  resources :users
  
   authenticated :user do
    root "pages#home", as: :authenticated_root
  end
  
  # Unauthenticated user routes
  unauthenticated do
    root "pages#landing_page"
  end
  
  get 'pages/home'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
end
