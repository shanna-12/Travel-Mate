class Chat < ApplicationRecord
  belongs_to :itinerary
  belongs_to :user
  has_many :messages, dependent: :destroy
end
