class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users, id: false do |t|
      t.string :id, primary_key: true, null: false # rubocop:disable Rails/DangerousColumnNames
      t.string :email
      t.string :name
      t.string :password_digest

      t.timestamps
    end

    add_index :users, :email, unique: true
  end
end
