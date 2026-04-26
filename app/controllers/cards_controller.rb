require "csv"

class CardsController < ApplicationController
  PHOTO_DIR = Rails.root.join("storage", "photos").freeze

  def index
    @cards = Card.order(:box, :name)
  end

  def destroy
    Card.find(params[:id]).destroy
    redirect_to cards_path, notice: "Card removed."
  end

  def import
    # GET — show the upload form
  end

  def do_import
    csv_file = params[:csv]
    photos   = Array(params[:photos])

    unless csv_file.present?
      redirect_to import_cards_path, alert: "Please choose a CSV file." and return
    end

    FileUtils.mkdir_p(PHOTO_DIR)
    saved_photos = []
    photos.each do |upload|
      next if upload.blank?
      basename = File.basename(upload.original_filename)
      File.binwrite(PHOTO_DIR.join(basename), upload.read)
      saved_photos << basename
    end

    rows = CSV.parse(csv_file.read, headers: true)
    created = 0
    rows.each do |row|
      name = row["name"] || row["Name"]
      photo = row["photo"] || row["Photo"] || row["photo_filename"]
      next if name.blank?
      Card.create!(name: name.strip, photo_filename: photo&.strip, box: 1)
      created += 1
    end

    redirect_to root_path,
      notice: "Imported #{created} card(s)#{saved_photos.any? ? " and saved #{saved_photos.size} photo(s)" : ""}."
  end

  def reset
    Card.update_all(box: 1, last_reviewed_at: nil)
    redirect_to root_path, notice: "All cards reset to box 1."
  end
end
