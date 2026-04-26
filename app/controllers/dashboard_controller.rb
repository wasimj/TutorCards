class DashboardController < ApplicationController
  def index
    @total = Card.count
    @due   = Card.due.count
    @by_box = (1..Card.const_get(:MAX_BOX)).map { |b| [b, Card.where(box: b).count] }.to_h
  end
end
