require 'spec_helper'

RSpec.describe "SolidusViabill::Api::Checkouts", type: :request do
  let(:spree_user) { create(:user_with_addresses) }
  let(:spree_address) { spree_user.addresses.first }
  let(:order) {
    create(
      :order,
      bill_address: spree_address,
      ship_address: spree_address,
      user: spree_user,
      state: :payment
    )
  }
  let(:payment_method) { create(:viabill_payment_method) }

  around do |test|
    Rails.application.routes.draw do
      get '/api/checkout_authorize', to: 'solidus_viabill/api/checkout#authorize', as: 'viabill_checkout_authorize'
      get '/api/checkout_callback', to: 'solidus_viabill/api/checkout#callback', as: 'viabill_checkout_callback'
      get '/api/checkout_success', to: 'solidus_viabill/api/checkout#success', as: 'viabill_checkout_success'

      mount Spree::Core::Engine, at: '/'
    end
    test.run
    Rails.application.reload_routes!
  end

  before do
    # rubocop:disable RSpec/AnyInstance
    allow_any_instance_of(Spree::Core::ControllerHelpers::Order).to receive(:current_order).and_return(order)
    # rubocop:enable RSpec/AnyInstance
  end

  describe '#authorize' do
    context 'when respond to json from frontend' do
      before do
        get viabill_checkout_authorize_path({
          format: :json,
          params: {
            payment_method_id: payment_method.id,
            frontend: true,
            order_number: order.number
          }
        })
      end

      it 'has http status 200' do
        expect(response.status).to eq(200)
      end

      it 'has correct keys in response body' do
        expect(JSON.parse(response.body).keys).to eq ['body']
      end

      it 'has correct data type for response body' do
        expect(JSON.parse(response.body).class).to eq 'Hash'.constantize
      end
    end

    context 'when respond to json from backend' do
      before do
        get viabill_checkout_authorize_path({
          format: :json,
          params: {
            payment_method_id: payment_method.id,
            frontend: false,
            order_number: order.number
          }
        })
      end

      it 'has http status 200' do
        expect(response.status).to eq(200)
      end

      it 'has correct keys in response body' do
        expect(JSON.parse(response.body).keys).to eq ['body']
      end

      it 'has correct data type for response body' do
        expect(JSON.parse(response.body).class).to eq 'Hash'.constantize
      end
    end
  end

  describe '#success' do
    context 'when respond to html from frontend' do
      before do
        create(:viabill_payment_method)
        get viabill_checkout_success_path({
          params: {
            payment_method_id: payment_method.id,
            frontend: true,
            order_number: order.number
          }
        })
      end

      it 'has http status 302' do
        expect(response.status).to eq(302)
      end

      it 'redirects to correct location' do
        expect(response).to redirect_to '/checkout/confirm'
      end
    end

    context 'when respond to html from backend' do
      before do
        create(:viabill_payment_method)
        get viabill_checkout_success_path({
          params: {
            payment_method_id: payment_method.id,
            frontend: false,
            order_number: order.number
          }
        })
      end

      it 'has http status 302' do
        expect(response.status).to eq(302)
      end

      it 'redirects to correct location' do
        expect(response).to redirect_to "/admin/orders/#{order.number}/confirm"
      end
    end
  end

  describe '#callback' do
    before { post viabill_checkout_callback_path }

    it 'has http status 200' do
      expect(response.status).to eq(200)
    end
  end
end
