class CreateItineraries < ActiveRecord::Migration[8.1]
  def change
    create_table :itineraries do |t|
      t.string :destination
      t.string :holiday_type
      t.date :start_date
      t.date :end_date
      t.integer :adults
      t.integer :children
      t.integer :budget
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
