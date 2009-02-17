class CreateBisCodes < ActiveRecord::Migration
  def self.up
    create_table :bis_codes do |t|
      t.integer :parent_id
      t.string :full_code, :own_code, :label
      t.text :description

      t.timestamps
    end
  end

  def self.down
    drop_table :bis_codes
  end
end
