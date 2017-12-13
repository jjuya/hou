class CreateLists < ActiveRecord::Migration
  def change
    create_table :lists do |t|
      t.string :title, null: false, default: "list"

      t.references :board, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
