class CreateAsks < ActiveRecord::Migration
  def self.up
    create_table :asks do |t|
      t.integer :price
      t.float :amount
      t.string :currency
      t.string :status, :null => false
      t.references :user
      t.timestamps
      t.timestamps
    end
  end

  def self.down
    drop_table :asks
  end
end
