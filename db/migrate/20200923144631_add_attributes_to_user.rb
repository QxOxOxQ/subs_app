class AddAttributesToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :zip_code, :string
    add_column :users, :credit_card_token, :string
    add_column :users, :address, :string
    add_column :users, :name, :string
  end
end
