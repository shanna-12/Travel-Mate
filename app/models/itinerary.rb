class Itinerary < ApplicationRecord
  after_initialize do
    self.holiday_type ||= "Adventure"
  end
  belongs_to :user
  has_many :chats, dependent: :destroy

  validate :end_date_after_start_date

  def end_date_after_start_date
    return if start_date.blank? || end_date.blank?
    return if end_date >= start_date

    errors.add(:end_date, "must be on or after the start date")
  end
end
