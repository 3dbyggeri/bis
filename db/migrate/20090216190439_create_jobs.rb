class CreateJobs < ActiveRecord::Migration
  def self.up
    create_table :jobs do |t|
      t.integer :progress, :default => 0
      t.boolean :success, :default => false
      t.string :message
      t.text :args, :report
      t.timestamps
    end
  end

  def self.down
    drop_table :jobs
  end
end
