class StudyController < ApplicationController
  def show
    @card = Card.due.order(Arel.sql("RANDOM()")).first
    @remaining = Card.due.count
    @total     = Card.count
  end

  def grade
    card = Card.find(params[:id])
    case params[:result]
    when "got_it"  then card.promote!
    when "missed"  then card.demote!
    end
    redirect_to study_path
  end
end
