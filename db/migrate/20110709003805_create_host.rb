class CreateHost < ActiveRecord::Migration
  def self.up
    create_table :hosts do |t|
      t.string :ip_address, :null => false, :length => 60
      t.references :user
      t.timestamps
    end
  end

  def self.down
    remove_column :table_name, :column_name
    drop_table :hosts
  end
end
