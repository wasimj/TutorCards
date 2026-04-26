require "csv"
require "fileutils"

sample_csv = Rails.root.join("db/sample/students.csv")
sample_dir = Rails.root.join("db/sample/photos")
photo_dir  = CardsController::PHOTO_DIR

FileUtils.mkdir_p(photo_dir)
Dir[sample_dir.join("*")].each { |src| FileUtils.cp(src, photo_dir.join(File.basename(src))) }

CSV.foreach(sample_csv, headers: true) do |row|
  name = row["name"].to_s.strip
  next if name.empty?
  Card.find_or_create_by!(name: name) do |c|
    c.photo_filename = row["photo"].to_s.strip
    c.box = 1
  end
end

puts "Seeded #{Card.count} cards."
