class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.string :title
      t.text :description
      t.string :itemtype

      t.timestamps null: false
    end
  end
end
