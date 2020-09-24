# frozen_string_literal: true

module Subscriptions
  class Create < Base
    include Dry::Monads::Result::Mixin
    include Dry::Matcher.for(:call, with: Dry::Matcher::ResultMatcher)

    def initialize(user, credit_card, product_id)
      super(user, product_id)
      @credit_card = credit_card
    end

    def call
      subscription = purchase(product.price)
      super(subscription)
    rescue APIInvalidError => e
      Failure(message: e.message, type: :invalid)
    rescue Api::FakePay::Client::API_ERROR => e
      Failure(message: e.message, type: :api_error)
    end

    private

    def purchase(product_price)
      fake_pay_client = Api::FakePay::Client.new
      response = fake_pay_client.card_purchase(product_price,
                                               @credit_card)
      if response['success'] == true
        add_credit_card_token_to_user(response['token'])
        create_subscription
      else
        raise APIInvalidError, ErrorCodes[response['error_code']]
      end
    end

    def add_credit_card_token_to_user(token)
      @user.update!(credit_card_token: token)
    end

    def create_subscription
      Subscription.create!(user: @user,
                           product: product,
                           end_date: Date.today.next_month)
    end
  end
end
