class CreateTransactions < ActiveRecord::Migration[5.2]
  def change
    create_table :transactions do |t|
      t.integer :user_id
      t.string :eth_hash
      t.jsonb :data

      t.timestamps
    end

    add_index :transactions, :user_id
    add_index :transactions, :eth_hash

    add_foreign_key :transactions, :users
  end
end
