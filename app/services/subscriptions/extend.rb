# frozen_string_literal: true

module Subscriptions
  class Extend < Base
    def self.call
      Subscription.where(end_date: Date.today).each do |subscription|
        Update(subscription)
      end
    end
  end
end
