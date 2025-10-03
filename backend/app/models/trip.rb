class Trip < ApplicationRecord
  belongs_to :user

  validates :title, presence: true
  validate :end_date_after_start_date

  private

  def end_date_after_start_date
    return unless start_date && end_date

    errors.add(:end_date, "must be after start date") if end_date < start_date
  end
end
