WebsiteOne::Application.routes.draw do
  mount Mercury::Engine => '/'
  
  root 'visitors#index'

  devise_for :users, controllers: { omniauth_callbacks: 'user_authentications' , :registrations => 'registrations'}
  devise_scope :user do
    delete '/users/auth/:provider', to: "user_authentications#destroy", as: :user_omniauth_destroy
  end

  resources :users, :only => [:index, :show] , :format => false

  resources :articles, :format => false

  match '/hangouts/:id' => 'hangouts#update', :via => [:put, :options], as: 'hangout'

  resources :projects, :format => false do
    member do
      get :follow
      get :unfollow
    end

  resources :documents, :format => false do
      put :mercury_update
      get :mercury_saved
    end
  end

  resources :events, :format => false do
    member do
      patch :update_only_url
    end
  end

  get '/verify/:id' => redirect {|params,request| "http://av-certificates.herokuapp.com/verify/#{params[:id]}"}

  post 'preview/article', to: 'articles#preview',:format => false
  patch 'preview/article', to: 'articles#preview', as: 'preview_articles', :format => false

  get 'projects/:project_id/:id', to: 'documents#show',:format => false
  post 'mail_contact_form', to: 'visitors#send_contact_form', :format => false
  post 'mail_hire_me_form', to: 'users#hire_me_contact_form' , :format => false

  put '*id/mercury_update', to: 'static_pages#mercury_update', as: 'static_page_mercury_update', :format => false
  get '*id/mercury_saved', to: 'static_pages#mercury_saved', as: 'static_page_mercury_saved', :format => false

  get '*id', to: 'static_pages#show', as: 'static_page', :format => false
end

