class AddSummaryToItineraries < ActiveRecord::Migration[8.1]
  def change
    add_column :itineraries, :summary, :text
  end
end
