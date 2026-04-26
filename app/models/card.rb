class Card < ApplicationRecord
  # Leitner boxes: 1 = hardest (review every session), 5 = easiest (rarely).
  # Intervals (days) before a card in box N is considered due again.
  BOX_INTERVALS = { 1 => 0, 2 => 1, 3 => 3, 4 => 7, 5 => 14 }.freeze
  MAX_BOX = 5
  MIN_BOX = 1

  validates :name, presence: true

  scope :due, -> {
    where(
      "last_reviewed_at IS NULL OR " +
      BOX_INTERVALS.keys.map { "(box = ? AND last_reviewed_at <= ?)" }.join(" OR "),
      *BOX_INTERVALS.flat_map { |box, days| [box, days.days.ago] }
    )
  }

  def promote!
    update!(box: [box + 1, MAX_BOX].min, last_reviewed_at: Time.current)
  end

  def demote!
    update!(box: MIN_BOX, last_reviewed_at: Time.current)
  end

  def due?
    return true if last_reviewed_at.nil?
    interval = BOX_INTERVALS[box] || 0
    last_reviewed_at <= interval.days.ago
  end
end
