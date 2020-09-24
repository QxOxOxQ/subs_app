module Subscriptions
  class Update < Base
    include Dry::Monads::Result::Mixin
    include Dry::Matcher.for(:call, with: Dry::Matcher::ResultMatcher)

    def initialize(subscription)
      @subscription = subscription
      @product = subscription.product
      @user = subscription.user
    end

    def call
      purchase(@product.price)
      super(@subscription)
    rescue APIInvalidError => e
      Failure(message: e.message, type: :invalid)
    rescue Api::FakePay::Client::API_ERROR => e
      Failure(message: e.message, type: :api_error)
    end

    private

    def purchase(product_price)
      fake_pay_client = Api::FakePay::Client.new
      response = fake_pay_client.token_purchase(product_price,
                                                @user.credit_card_token)
      if response['success'] == true
        update_subscription
      else
        raise APIInvalidError, ErrorCodes[response['error_code']]
      end
    end

    def update_subscription
      @subscription.update!(end_date: Date.today.next_month)
      @subscription
    end
  end
end
