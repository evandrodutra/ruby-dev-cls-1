class CreateDirectories < ActiveRecord::Migration[8.0]
  def change
    create_table :directories do |t|
      t.string :name, null: false
      t.integer :parent_id, foreign_key: { to_table: :directories }, index: true, null: true

      t.timestamps
    end
  end
end
