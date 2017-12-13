class CreateBookmarks < ActiveRecord::Migration
  def change
    create_table :bookmarks do |t|
      t.string :title, null:false, default: "bookmark"
      t.string :url, null: false
      t.text :description
      t.string :tag_1
      t.string :tag_2
      t.string :tag_3
      t.integer :rating, null: false, default: 0

      t.references :list, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
