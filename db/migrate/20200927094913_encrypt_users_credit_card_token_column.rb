class EncryptUsersCreditCardTokenColumn < ActiveRecord::Migration[6.0]
  def change
    remove_column :users, :credit_card_token, :string
    add_column :users, :encrypted_credit_card_token, :string
    add_column :users, :encrypted_credit_card_token_iv, :string

    add_index :users, :encrypted_credit_card_token_iv, unique: true
  end
end
