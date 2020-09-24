module Api
  module V1
    class SubscriptionsController < ApplicationController
      def create
        current_user.update!(name: shipping_params[:name],
                             address: shipping_params[:address],
                             zip_code: shipping_params[:zip_code])

        service = Subscriptions::Create.new(current_user,
                                            credit_card_params,
                                            product_params)
        service.call { |result| render_result(result) }
      end

      def destroy
        subscription = current_user.subscriptions.find(params[:id])
        subscription.destroy
      end

      private

      def credit_card_params
        params.require(:credit_card).permit(%i[card_number expiration_month expiration_year cvv zip_code])
      end

      def shipping_params
        params.require(:shipping).permit(%i[name address zip_code])
      end

      def product_params
        params.require(:product_id)
      end
    end
  end
end
