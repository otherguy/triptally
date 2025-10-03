class CreateTrips < ActiveRecord::Migration[8.0]
  def change
    create_table :trips do |t|
      t.string :title
      t.text :description
      t.date :start_date
      t.date :end_date
      t.string :user_id, null: false

      t.timestamps
    end

    add_index :trips, :user_id
    add_foreign_key :trips, :users
  end
end
