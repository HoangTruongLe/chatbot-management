Rails.application.routes.draw do
  resources :chatbot_emotion_photos
  resources :chatbots
  # Rails Admin
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  # Authen by Devise
  devise_for :users

  # API
  api_version(:module => "V1", :path => {:value => "v1"}, :defaults => {:format => "json"}) do
    # resources :api_statistics
    resources :messages
    post 'user_message', to: 'input_statistic#create'
    post 'user_click', to: 'click_statistic#create'
    post 'user_dislike', to: 'dislike_statistic#create'

    post 'start_chatbot', to: 'session_statistic#create'
    post 'update_statistic', to: 'session_statistic#update'

    resources :categories
    resources :products do
      member do
        get 'chatbot_show_product', :defaults => { :format => 'json' }
      end
      collection do
        get 'chatbot_show_products'
      end
    end
    get 'get_message', to: 'messages#get_message'
    get 'existed_open_keyword', to: 'messages#existed_open_keyword'
    post 'display_statistic', to: 'api_statistics#display_statistic'
    post 'click_statistic', to: 'api_statistics#click_statistic'

    post 'send_chatbot_log', to: 'chatbot_logs#send_chatbot_log'

    post 'update_conversation_status', to: 'conversation_status#update_conversation_status'
    get 'render_conversation', to: 'conversation_status#render_conversation'
    post 'update_chatting', to: 'conversation_status#update_chatting'

    post 'user_access', to: 'user_accesses#user_access'
  end

  # Web System
  root to: "home#index"

  get '/profile', to: 'home#user_profile'
  patch '/profile', to: 'home#update_user'

  get 'statistics/products', to: 'statistics#products'
  get 'statistics/sessions', to: 'statistics#sessions'
  get 'statistics/conversations/:id', to: 'statistics#conversations', as: 'conversation_messages'

  resources :apikey, only: [:index] do
    collection do
      post :generate_new_api_key
    end
  end
  resources :categories do
    member do
      get :logs
      get :show_log
    end
  end
  resources :products do
    collection do
      post :import_csv
      get :export_csv, defaults: { format: :csv }
      get :export_report, defaults: { format: :csv }
    end
    member do
      get :logs
      get :show_log
    end
  end
  resources :messages do
    member do
      put 'update_primary_keyword'
      post 'create_relative_keyword'
      delete 'destroy_relative_keyword'
      get 'get_relative_keywords'
      put 'update_message_tag'
      get 'get_tag_messages'
      get 'message_preview'
      get 'copy_message'
      get :message_detail_report, defaults: { format: :csv }
    end
    collection do
      get :product, as: :message_product_search
      get :summary_message_report, defaults: { format: :csv }
    end
  end
  put 'messages/:id/update_message_type/:message_type', to: 'messages#update_message_type'
  put 'messages/:id/update_message_activity/:message_activity', to: 'messages#update_message_activity'
  put 'messages/:id/update_message_priority/:message_priority', to: 'messages#update_message_priority'

  resources :sites
  resources :users
  resources :photos, except: [:show, :destroy]
  resources :link_cards
  resources :message_contents
  resources :questions
  resources :stories, only: [:index, :show] do
    collection do
      get :story_report, defaults: { format: :csv }
    end
    member do
      get :messages_report, defaults: { format: :csv }
    end
  end

  namespace :master do
    resources :master_categories
    resources :tags
    resources :keywords do
      collection do
        post :import_csv
        get :export_csv, defaults: { format: :csv }
      end
    end
  end
  resources :videos, except: [:show, :destroy]
  get 'photos/message_photos', to: 'photos#message_photos'
  get 'photos/message_photo_group', to: 'photos#message_photo_group'
  delete 'photos/:id/destroy_photo_group/:content_id', to: 'photos#destroy_photo_group'
  delete 'photos/:id', to: 'photos#destroy'
  get 'videos/message_video', to: 'videos#message_video'
  get 'videos/message_video_group', to: 'videos#message_video_group'
  delete 'videos/:id/destroy_video_group/:content_id', to: 'videos#destroy_video_group'
  delete 'videos/:id', to: 'videos#destroy'
  resources :quotes
  resources :text_messages
  resources :product_messages
end
