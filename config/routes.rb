# frozen_string_literal: true

Rails.application.routes.draw do
  root "login#index"

  resource :session, only: [:create, :destroy]

  get "/login", to: "login#index"
  post "/login", to: "login#create"
  delete "/logout", to: "logout#destroy"

  resources :capture_payment_data, only: [:index], path: "capture_payment_data" do
    post :capture, on: :collection
  end

  resources :payment_data, only: [:index]
  resources :journal_entry_data, only: [:index]
  post "/journal_entry_data/display", to: "journal_entry_data#display", as: :journal_entry_data_display
  post "/journal_entry_data/export", to: "journal_entry_data#export", as: :journal_entry_data_export
  resources :companies, only: [:index]
  resources :departments, only: [:index]
  resources :capture_categories, only: [:index]
  resources :suppliers, only: [:index]
  resources :journal_entry_patterns, only: [:index]
  resources :users
end
