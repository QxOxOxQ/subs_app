module Api
  module V1
    class SubscriptionsController < ApplicationController
      def create
        service = Subscriptions::Create.new(current_user,
                                            subscription_params[:credit_card],
                                            subscription_params[:product_id])
        service.call { |result| render_result(result) }
      end

      def destroy
        subscription = current_user.subscriptions.find(params[:id])
        subscription.destroy
      end

      private

      def subscription_params
        params.require(:credit_card).permit(%i[card_number expiration_month expiration_year cvv zip_code])
        params.require(:shipping).permit(%i[name address zip_code])
        params.require(:product_id)
        params
      end
    end
  end
end
