# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Subscriptions::Update, type: :service do
  let!(:product) { create(:product) }
  let(:token) { 'd8ae63db5661d48df4fb0db246db79' }
  let!(:user) { create(:user, credit_card_token: token) }
  let!(:subscription) { create(:subscription, user: user, product: product, end_date: Date.today) }

  subject { described_class.new(subscription) }

  context 'without errors' do
    before do
      api_double = double(Api::FakePay::Client)
      allow(Api::FakePay::Client).to receive(:new) { api_double }
      allow(api_double).to receive(:token_purchase).with(product.price, user.credit_card_token) do
        { 'token' => token, 'success' => true, 'error_code' => nil }
      end
    end

    it 'update subscription' do
      subject.call
      expect(subscription.reload.end_date).to eq Date.today.next_month
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
      allow(api_double).to receive(:token_purchase) { { 'success' => false, 'error_code' => 1_000_007 } }
    end

    it 'NO update subscription' do
      old_end_date = subscription.end_date
      subject.call
      expect(subscription.reload.end_date).to eq old_end_date
    end

    it 'response failure' do
      failuer_obj = subject.call.failure
      expect(failuer_obj[:message]).to eq 'Invalid token'
      expect(failuer_obj[:type]).to eq :invalid
    end
  end

  context 'with api error' do
    before do
      api_double = double(Api::FakePay::Client)
      allow(Api::FakePay::Client).to receive(:new) { api_double }
      allow(api_double).to receive(:token_purchase).and_raise(Api::FakePay::Client::API_ERROR, 'message')
    end

    it 'NO create subscription' do
      old_end_date = subscription.end_date
      subject.call
      expect(subscription.reload.end_date).to eq old_end_date
    end

    it 'response failure' do
      failure_obj = subject.call.failure
      expect(failure_obj[:message]).to eq 'message'
      expect(failure_obj[:type]).to eq :api_error
    end
  end
end
