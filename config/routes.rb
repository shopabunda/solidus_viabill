# frozen_string_literal: true

Spree::Core::Engine.routes.draw do
  get '/checkout_authorize', to: '/solidus_viabill/checkout#authorize', as: 'viabill_checkout_authorize'
  get '/checkout_callback', to: '/solidus_viabill/checkout#callback', as: 'viabill_checkout_callback'
  get '/checkout_success', to: '/solidus_viabill/checkout#success', as: 'viabill_checkout_success'
end
