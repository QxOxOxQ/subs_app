class User < ApplicationRecord
  devise :database_authenticatable,
         :registerable,
         :jwt_authenticatable, jwt_revocation_strategy: Blacklist
  has_many :subscriptions, dependent: :destroy
  has_many :products, through: :subscriptions

  validates :email, uniqueness: true

  attr_encrypted :credit_card_token, key: [Rails.application.credentials[:user][:credit_card_token_encryption_key]].pack('H*')
end
