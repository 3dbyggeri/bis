class CreateReferences < ActiveRecord::Migration
  def self.up
    create_table :bis_code_references do |t|
      t.integer :reference_id
      t.integer :referrer_id
      t.string :description

      t.timestamps
    end
  end

  def self.down
    drop_table :bis_code_references
  end
end
