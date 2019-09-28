# frozen_string_literal: true

require 'rails_helper'

module Request
  module JsonHelpers
    def json
      JSON.parse(response.body)
    end
  end
end