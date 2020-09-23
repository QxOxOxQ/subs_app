class Product < ApplicationRecord
  validates :name, :price, presence: true
  validates :price, numericality: { greater_than: 0 }

  has_many :subscriptions
  has_many :users, through: :subscriptions
end
