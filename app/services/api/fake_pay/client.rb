# frozen_string_literal: true

module Api
  module FakePay
    class Client
      API_ENDPOINT = 'https://www.fakepay.io'

      def initialize
        @token = Rails.application.credentials[:api_keys][:fake_pay]
      end

      def card_purchase(amount, card_attr)
        request(
          http_method: :post,
          endpoint: 'purchase',
          params: {
            amount: amount,
            card_number: card_attr[:card_number],
            cvv: card_attr[:cvv],
            expiration_month: card_attr[:expiration_month],
            expiration_year: card_attr[:expiration_year],
            zip_code: card_attr[:zip_code]
          }
        )
      end

      def token_purchase(amount, token)
        request(
          http_method: :post,
          endpoint: 'purchase',
          params: {
            amount: amount,
            token: token
          }
        )
      end

      private

      def client
        @client ||= Faraday.new(API_ENDPOINT) do |client|
          client.request :url_encoded
          client.adapter Faraday.default_adapter
          client.headers['Authorization'] = "Token token=#{@token}"
        end
      end

      def request(http_method:, endpoint:, params: {})
        response = client.public_send(http_method, endpoint, params)
        Oj.load(response.body)
      end
    end
  end
end
