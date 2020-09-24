# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::SubscriptionsController, type: :request do
  let!(:product) { create(:product) }
  let!(:user) { create(:user) }
  let(:shipping) do
    { name: 'Brzęczyszczykiewicz', address: 'Kraków', zip_code: '01-202' }
  end

  describe 'POST api/v1/subscriptions' do
    before { sign_in user }
    subject do
      post '/api/subscriptions', params: { format: :json,
                                           credit_card: credit_card,
                                           shipping: shipping,
                                           product_id: product.id }
    end
    context 'with correct attributes' do
      let(:credit_card) do
        { card_number: 4_242_424_242_424_242,
          expiration_month: '01',
          expiration_year: '2024',
          cvv: '123',
          zip_code: '01-202' }
      end

      before { VCR.insert_cassette 'success_subscription' }
      after { VCR.eject_cassette }

      it 'create subscription' do
        expect { subject }.to change(Subscription, :count).by(1)
        subscription = Subscription.last
        expect(subscription.user).to eq user
        expect(subscription.product).to eq product
      end

      it 'add credit card token to user' do
        subject
        expect(user.credit_card_token).to eq 'fake_token_123456789'
      end

      it 'add shipping to user' do
        subject
        expect(user.name).to eq shipping[:name]
        expect(user.address).to eq shipping[:address]
        expect(user.zip_code).to eq shipping[:zip_code]
      end

      it 'response success' do
        subject
        expect(response).to have_http_status(:success)
        expect(json['id']).to_not be_nil
        expect(json['user_id']).to eq user.id
        expect(json['product_id']).to eq product.id
        expect(json['end_date']).to eq JSON.parse(Date.today.next_month.to_json)
      end
    end

    context 'with UNcorrect attributes' do
      let(:credit_card) do
        { card_number: 4_242_424_242_424_242,
          expiration_month: '01',
          expiration_year: '1024',
          cvv: '123',
          zip_code: '01-202' }
      end

      before { VCR.insert_cassette 'fail_subscription' }
      after { VCR.eject_cassette }

      it 'NO create subscription' do
        expect { subject }.to_not change(Subscription, :count)
      end

      it 'NO add credit card token to user' do
        subject
        expect(user.credit_card_token).to eq nil
      end

      it 'add shipping to user' do
        subject
        expect(user.name).to eq shipping[:name]
        expect(user.address).to eq shipping[:address]
        expect(user.zip_code).to eq shipping[:zip_code]
      end

      it 'response faile' do
        subject
        expect(response).to have_http_status(:bad_request)
        expect(json).to eq(
          'error' =>
              {
                'message' => 'Expired card',
                'type' => 'invalid'
              }
        )
      end
    end
  end
end
