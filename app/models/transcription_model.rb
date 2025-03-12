class Transcription < ApplicationRecord
  validates :original_filename, presence: true, uniqueness: true
  validates :transcription, allow_nil: true, length: { maximum: 10_000 }
end
