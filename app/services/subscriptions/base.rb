# frozen_string_literal: true

require 'dry/monads/result'
require 'dry/matcher/result_matcher'

module Subscriptions
  class Base
    APIInvalidError = Class.new(StandardError)
    ErrorCodes = { 1_000_001 => 'Invalid credit card number',
                   1_000_002 => 'Insufficient funds',
                   1_000_003 => 'CVV failure',
                   1_000_004 => 'Expired card',
                   1_000_005 => 'Invalid zip code',
                   1_000_006 => 'Invalid purchase amount',
                   1_000_007 => 'Invalid token',
                   1_000_008 => 'Invalid params: cannot specify both  token  and other credit card params like  card_number ,  cvv ,  expiration_month ,  expiration_year  or  zip ' }.freeze

    def initialize(user, product_id)
      @user = user
      @product_id = product_id
    end

    def call(subscription)
      Success(subscription: { id: subscription.id,
                              user_id: subscription.user_id,
                              product_id: subscription.product.id,
                              end_date: subscription.end_date })
    end

    private

    def product
      @product ||= Product.find(@product_id)
    end
  end
end
