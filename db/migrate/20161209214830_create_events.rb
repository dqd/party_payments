class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :uuid
      t.integer :requestor_id
      t.string :eventable_type
      t.integer :eventable_id
      t.string :name
      t.text :metadata
      t.text :data

      t.timestamps
    end
  end
end
