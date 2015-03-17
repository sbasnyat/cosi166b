class ChangeItemsAndAddTypes < ActiveRecord::Migration
  def change


  add_column :items, :owner, :text
  remove_column :items, :itemtype, :string
  add_column :items, :type_id, :integer


  	create_table :types do |t|
      t.string :title
      t.string :description

      t.timestamps null: false
    end

  end
end
