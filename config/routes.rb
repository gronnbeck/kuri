Rails.application.routes.draw do
  mount ActionCable.server => "/cable"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  root "home#index"
  get "practice", to: "practice#index"
  get "practice/word_guess", to: "practice#word_guess"
  post "practice/word_guess", to: "practice#do_word_guess"
  get "practice/sentence_transformation", to: "practice#sentence_transformation"
  post "practice/sentence_transformation", to: "practice#check_sentence_transformation"
  get "practice/guided_translation", to: "practice#guided_translation"
  post "practice/guided_translation/generate", to: "practice#generate_translation_sentence", as: :generate_translation_sentence
  get "practice/guided_translation/exercise", to: "practice#guided_translation_exercise", as: :guided_translation_exercise
  post "practice/guided_translation/exercise", to: "practice#check_guided_translation", as: :check_guided_translation
  get "practice/daily_conversations", to: "practice#daily_conversations", as: :practice_daily_conversations
  get "practice/daily_conversations/exercise", to: "practice#daily_conversations_exercise", as: :daily_conversations_exercise
  post "practice/daily_conversations/exercise", to: "practice#check_daily_conversation", as: :check_daily_conversation
  get "practice/useful_phrases", to: "practice#useful_phrases", as: :practice_useful_phrases
  get "practice/useful_phrases/exercise", to: "practice#useful_phrases_exercise", as: :useful_phrases_exercise
  post "practice/useful_phrases/exercise", to: "practice#check_useful_phrase", as: :check_useful_phrase
  get "practice/micro_sentences", to: "practice#micro_sentences"
  get "practice/word_hint", to: "practice#word_hint"
  get "practice/jp_word_hint", to: "practice#jp_word_hint"
  get "practice/sentence_patterns/exercise", to: "practice#sentence_patterns_exercise", as: :practice_sentence_patterns_exercise
  post "practice/sentence_patterns/exercise", to: "practice#check_sentence_pattern", as: :check_sentence_pattern
  get "practice/sentence_patterns", to: "practice#sentence_patterns"
  get "audio_clips", to: "audio_clips#index"
  get "audio_clips/generate", to: "audio_clips#generate", as: :audio_clips_generate
  post "audio_clips/generate", to: "audio_clips#create", as: :audio_clips_create
  get "audio_clips/:id/audio", to: "audio_clips#audio", as: :audio_audio_clip
  resources :conversation_exercises do
    collection do
      post :generate
    end
    member do
      post :add_to_anki
      post :generate_audio
      post :regenerate_audio
      post :confirm_audio
      post :discard_pending_audio
      post :archive
      post :improve
      post :generate_readings
    end
    resources :conversation_feedbacks, only: [ :create, :destroy ]
  end
  get "conversation_audios/:id/audio", to: "conversation_audios#audio", as: :conversation_audio

  resources :verb_transformation_exercises do
    collection do
      post :generate
    end
    member do
      post :add_to_anki
      post :generate_audio
      post :archive
      post :improve
      post :generate_readings
    end
    resources :verb_transformation_feedbacks, only: [ :create, :destroy ]
  end
  get "verb_audios/:id/audio", to: "verb_audios#audio", as: :verb_audio

  resources :conversation_batches, only: [ :index, :new, :create, :show ]
  resources :verb_batches,         only: [ :index, :new, :create, :show ]

  get "settings", to: "settings#index"
  get "settings/listen", to: "settings#listen", as: :settings_listen
  get "settings/listen/card_templates", to: "settings/card_templates#show", as: :settings_listen_card_templates
  scope "/settings/listen", as: "settings_listen" do
    resources :actors
    resource :conversations, only: [ :show, :update ], controller: "settings/conversations" do
      collection do
        get  :fetch_decks
        get  :fetch_note_types
        get  :fetch_fields
        post :test_connection
      end
    end
    resource :verbs, only: [ :show, :update ], controller: "settings/verbs" do
      collection do
        get  :fetch_decks
        get  :fetch_note_types
        get  :fetch_fields
        post :test_connection
      end
    end
  end
  resources :note_enrichment_batches, only: [ :index, :new, :create, :show ] do
    member do
      post :approve_all
      post :reject_all
      post :push
    end
    resources :note_enrichments, only: [] do
      member do
        post :approve
        post :reject
      end
    end
  end

  resources :notes, only: [ :index, :show ]
  resources :decks, only: [ :index, :new, :create, :update, :destroy ] do
    collection do
      post :sync
    end
  end
end
