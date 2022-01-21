# frozen_string_literal: true

Spree::Core::Engine.routes.draw do
  get '/api/checkout_authorize', to: '/solidus_viabill/api/checkout#authorize', as: 'viabill_checkout_authorize'
  get '/api/checkout_callback', to: '/solidus_viabill/api/checkout#callback', as: 'viabill_checkout_callback'
  get '/api/checkout_success', to: '/solidus_viabill/api/checkout#success', as: 'viabill_checkout_success'
end
