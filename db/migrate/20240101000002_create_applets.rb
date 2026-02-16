class CreateApplets < ActiveRecord::Migration[8.0]
  def change
    create_table :applets do |t|
      t.string :name, null: false
      t.text :description
      t.references :trigger_service, null: false, foreign_key: { to_table: :services }
      t.references :action_service, null: false, foreign_key: { to_table: :services }
      t.boolean :enabled, default: true, null: false

      t.timestamps
    end
  end
end
