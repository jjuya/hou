class CreateBoards < ActiveRecord::Migration
  def change
    create_table :boards do |t|
      t.string :title, null: false, default: "board"
      t.boolean :starred, null: false, default: false

      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
