class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :name
      t.string :password_digest
      t.string :eth_address
      t.string :eth_password

      t.timestamps
    end

    add_index :users, :name
  end
end
