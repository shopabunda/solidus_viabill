require 'spec_helper'

RSpec.describe 'SolidusViabill::Checkouts', type: :request do
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

  around do |test|
    Rails.application.routes.draw do
      get '/checkout_authorize', to: 'solidus_viabill/checkout#authorize', as: "viabill_checkout_authorize"
      get '/checkout_success', to: 'solidus_viabill/checkout#success', as: 'viabill_checkout_success'

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
    context 'when respond to json' do
      before do
        get viabill_checkout_authorize_path({ format: :json })
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
    context 'when respond to html' do
      before do
        create(:viabill_payment_method)
        get viabill_checkout_success_path
      end

      it 'has http status 302' do
        expect(response.status).to eq(302)
      end

      it 'redirects to correct location' do
        expect(response).to redirect_to '/checkout/confirm'
      end
    end
  end
end
