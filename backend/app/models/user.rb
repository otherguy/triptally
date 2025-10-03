class User < ApplicationRecord
  has_secure_password
  has_many :trips, dependent: :destroy

  before_create :set_uuid

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, presence: true
  validates :password, length: { minimum: 6 }, if: -> { new_record? || !password.nil? }

  private

  def set_uuid
    self.id ||= UUID7.generate
  end
end
