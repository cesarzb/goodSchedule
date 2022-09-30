Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  namespace :api do
    namespace :v1 do
      resources :plans
      post '/register',        to: 'users#create'
      post '/change-password', to: 'users#change_password'
      #  get 'users/index'
      #  delete 'users/:id/destroy'
      post   '/login',  to: 'authentication#create'
      delete '/logout', to: 'authentication#destroy'
    end
  end
end
