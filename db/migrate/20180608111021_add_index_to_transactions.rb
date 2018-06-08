class AddIndexToTransactions < ActiveRecord::Migration[5.2]
  def change
    add_index  :transactions, :data, using: :gin
  end
end
