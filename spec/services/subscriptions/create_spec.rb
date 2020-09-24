# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Subscriptions::Create, type: :service do
  let!(:product) { create(:product) }
  let!(:user) { create(:user) }
  let(:credit_card) do
    { card_number: 4_242_424_242_424_242,
      cvv: '123',
      expiration_month: '01',
      expiration_year: '024',
      zip_code: '01-202' }
  end
  let(:token) { 'd8ae63db5661d48df4fb0db246db79' }
  subject { described_class.new(user, credit_card, product.id) }

  context 'without errors' do
    before do
      api_double = double(Api::FakePay::Client)
      allow(Api::FakePay::Client).to receive(:new) { api_double }
      allow(api_double).to receive(:card_purchase) { { 'token' => token, 'success' => true, 'error_code' => nil } }
    end

    it 'create subscription' do
      expect { subject.call }.to change(Subscription, :count).by(1)
      subscription = Subscription.last
      expect(subscription.user).to eq user
      expect(subscription.product).to eq product
    end

    it 'add credit card token to user' do
      subject.call
      expect(user.credit_card_token).to eq token
    end

    it 'response success' do
      success_obj = subject.call.success
      expect(success_obj[:subscription][:user_id]).to eq user.id
      expect(success_obj[:subscription][:product_id]).to eq product.id
      expect(success_obj[:subscription][:end_date]).to eq Date.today.next_month
    end
  end

  context 'with api invalid error' do
    before do
      api_double = double(Api::FakePay::Client)
      allow(Api::FakePay::Client).to receive(:new) { api_double }
      allow(api_double).to receive(:card_purchase) { { 'success' => false, 'error_code' => 1_000_001 } }
    end

    it 'NO create subscription' do
      expect { subject.call }.to_not change(Subscription, :count)
    end

    it 'NO add credit card token to user' do
      subject.call
      expect(user.credit_card_token).to eq nil
    end

    it 'response failure' do
      failuer_obj = subject.call.failure
      expect(failuer_obj[:message]).to eq 'Invalid credit card number'
      expect(failuer_obj[:type]).to eq :invalid
    end
  end
  context 'with api error' do
    before do
      api_double = double(Api::FakePay::Client)
      allow(Api::FakePay::Client).to receive(:new) { api_double }
      allow(api_double).to receive(:card_purchase).and_raise(Api::FakePay::Client::API_ERROR, 'message')
    end

    it 'NO create subscription' do
      expect { subject.call }.to_not change(Subscription, :count)
    end

    it 'NO add credit card token to user' do
      subject.call
      expect(user.credit_card_token).to eq nil
    end

    it 'response failure' do
      failure_obj = subject.call.failure
      expect(failure_obj[:message]).to eq 'message'
      expect(failure_obj[:type]).to eq :api_error
    end
  end
end
