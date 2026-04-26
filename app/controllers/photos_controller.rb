class PhotosController < ApplicationController
  TYPES = {
    ".png" => "image/png", ".jpg" => "image/jpeg", ".jpeg" => "image/jpeg",
    ".gif" => "image/gif", ".webp" => "image/webp", ".svg" => "image/svg+xml"
  }.freeze

  def show
    filename = File.basename(params[:filename].to_s)
    path = CardsController::PHOTO_DIR.join(filename)
    if File.exist?(path)
      send_file path, type: TYPES[File.extname(filename).downcase] || "application/octet-stream",
                disposition: "inline"
    else
      head :not_found
    end
  end
end
