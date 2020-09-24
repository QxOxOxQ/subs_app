module Api
  module V1
    class SubscriptionsController < ApplicationController
      def create; end

      def destroy
        #  Subscriptions::Destroy.new.call
      end

      private

      def subscription_params
        params.require(billing: %i[card_number expiration_month expiration_day cvv zip_code])
        params.require(shipping: %i[name address zip_code])
        params.require(:product_id)
      end
    end
  end
end
