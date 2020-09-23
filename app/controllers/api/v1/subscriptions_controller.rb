module Api
  module V1
    class SubscriptionsController < ApplicationController
      def create
        #  Subscriptions::Create.new.call
      end

      def destroy
        #  Subscriptions::Destroy.new.call
      end

      private

      def subscription_params
        params.require(billing: [:card_number, :expiration_date, :cvv])
        params.require(shipping: [:name, :address, :zip_code])
        params.require(:product_id)
      end
    end
  end
end