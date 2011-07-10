class CreateSettings < ActiveRecord::Migration
  def self.up
    create_table :settings do |t|
      t.string :data, :null => false
      t.integer :user_id, :null => true
      t.string :setting_type, :limit => 30, :null => true
      t.timestamps
    end
    
    add_index :settings, [ :setting_type, :user_id]
  end

  def self.down
    drop_table :settings
  end
end
