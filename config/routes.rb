Rails.application.routes.draw do
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
  resources :audio_clips, only: [ :index, :create ] do
    member do
      get :audio
    end
  end
  get "settings", to: "settings#index"
  get "settings/listen", to: "settings#listen", as: :settings_listen
  scope "/settings/listen", as: "settings_listen" do
    resources :actors
  end
  resources :notes, only: [ :index, :show ]
  resources :decks, only: [ :index, :new, :create, :update, :destroy ] do
    collection do
      post :sync
    end
  end
end
