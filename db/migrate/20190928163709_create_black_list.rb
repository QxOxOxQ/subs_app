class CreateBlackList < ActiveRecord::Migration[6.0]
  def change
    create_table :blacklists do |t|
      t.string :jti, null: false
    end
    add_index :blacklists, :jti
  end
end
