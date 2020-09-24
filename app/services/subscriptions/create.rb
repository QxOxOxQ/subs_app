# frozen_string_literal: true

require 'dry/monads/result'
require 'dry/matcher/result_matcher'

module Subscriptions
  class Create
    include Dry::Monads::Result::Mixin
    include Dry::Matcher.for(:call, with: Dry::Matcher::ResultMatcher)

    APIInvalidError = Class.new(StandardError)
    ErrorCodes = { 1_000_001 => 'Invalid credit card number',
                   1_000_002 => 'Insufficient funds',
                   1_000_003 => 'CVV failure',
                   1_000_004 => 'Expired card',
                   1_000_005 => 'Invalid zip code',
                   1_000_006 => 'Invalid purchase amount',
                   1_000_007 => 'Invalid token',
                   1_000_008 => 'Invalid params: cannot specify both  token  and other credit card params like  card_number ,  cvv ,  expiration_month ,  expiration_year  or  zip ' }.freeze

    def initialize(user, credit_card, product_id)
      @user = user
      @credit_card = credit_card
      @product_id = product_id
    end

    def call
      subscription = purchase(product.price)
      Success(subscription: { id: subscription. id,
                              user_id: subscription.user_id,
                              product_id: subscription.product.id,
                              end_date: subscription.end_date })
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

    def product
      @product ||= Product.find(@product_id)
    end
  end
end
