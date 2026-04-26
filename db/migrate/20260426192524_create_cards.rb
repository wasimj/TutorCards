class CreateCards < ActiveRecord::Migration[8.1]
  def change
    create_table :cards do |t|
      t.string :name, null: false
      t.string :photo_filename
      t.integer :box, null: false, default: 1
      t.datetime :last_reviewed_at

      t.timestamps
    end
  end
end
