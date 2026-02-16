class CreateServices < ActiveRecord::Migration[8.0]
  def change
    create_table :services do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.string :icon_url
      t.string :brand_color

      t.timestamps
    end

    add_index :services, :slug, unique: true
  end
end
