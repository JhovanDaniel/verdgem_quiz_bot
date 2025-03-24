Rails.application.routes.draw do
  get 'subscribers/create'
  
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
  
  # Quiz routes
  get 'quiz/start', to: 'quiz#start', as: 'quiz_start'
  get 'quiz/question', to: 'quiz#question', as: 'quiz_question'
  post 'quiz/submit', to: 'quiz#submit', as: 'quiz_submit'
  get 'quiz/results', to: 'quiz#results', as: 'quiz_results'
  get 'quiz/history', to: 'quiz#history', as: 'quiz_history'
  get 'quiz/sessions', to: 'quiz#sessions', as: 'quiz_sessions'
  get 'quiz/quiz_select', to: 'quiz#quiz_select', as: 'quiz_select'
  get 'quiz/sessions/:id', to: 'quiz#show_session', as: 'quiz_session'
  get 'quiz/resume/:id', to: 'quiz#resume', as: 'resume_quiz'
  
  devise_for :users, controllers: {
    registrations: 'users/registrations'
  }
  
  get 'users/admin_new', to: 'users#admin_new', as: 'admin_new_user'
  post 'users/admin_create', to: 'users#admin_create', as: 'admin_create_user'
  get 'users/:id/admin_edit', to: 'users#admin_edit', as: 'admin_edit_user'
  patch 'users/:id/admin_update', to: 'users#admin_update', as: 'admin_update_user'
  
  resources :users
  
  authenticated :user, -> (user) { user.teacher? || user.admin? } do
    root to: "pages#teacher_dashboard", as: :teacher_root
  end
  
  authenticated :user, -> (user) { !user.teacher? && !user.admin? } do
    root to: "pages#home", as: :authenticated_root
  end

  # Create the actual routes for these dashboards
  get 'pages/home', to: 'pages#home'
  get 'pages/teacher_dashboard', to: 'pages#teacher_dashboard'
  
  # Unauthenticated user routes
  unauthenticated do
    root "pages#landing_page"
  end
  
  resources :subscribers, only: [:create]
  
  get 'pages/home'
  get 'pages/about'
  get 'pages/our_team'
  get 'pages/our_blog'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
end
