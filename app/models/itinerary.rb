class Itinerary < ApplicationRecord
  after_initialize do
    self.holiday_type ||= "Adventure"
  end
  belongs_to :user
  has_many :chats, dependent: :destroy
end
