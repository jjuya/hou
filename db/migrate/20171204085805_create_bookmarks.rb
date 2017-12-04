class CreateBookmarks < ActiveRecord::Migration
  def change
    create_table :bookmarks do |t|
      t.string :title
      t.string :url
      t.text :description
      t.string :tag_1
      t.string :tag_2
      t.string :tag_3
      t.integer :list_id

      t.timestamps null: false
    end
  end
end
