#!/usr/bin/env ruby
# Fetches a stock portrait per row in students.csv via the randomuser.me API.
# Each name has a gender + (optional) nationality hint so the photo at least
# loosely matches the name. The API's pool is small (~100 portraits per
# nationality), so collisions are possible across larger groups.
require "csv"
require "fileutils"
require "json"
require "net/http"
require "uri"

ROOT = File.expand_path("..", __FILE__)
PHOTOS = File.join(ROOT, "photos")
FileUtils.mkdir_p(PHOTOS)
Dir[File.join(PHOTOS, "*.{svg,jpg,jpeg,png}")].each { |f| File.delete(f) }

# name → [gender, nationality (or nil for any)]
HINTS = {
  "Alice Chen"      => [:female, nil],     # randomuser.me has no asian nat — leave open
  "Bilal Ahmed"     => [:male,   "in"],
  "Carmen Diaz"     => [:female, "es"],
  "Daniel O'Connor" => [:male,   "ie"],
  "Emma Watson"     => [:female, "gb"],
  "Farouk Patel"    => [:male,   "in"],
  "Grace Kim"       => [:female, nil],
  "Hiroshi Tanaka"  => [:male,   nil],
  "Isabella Rossi"  => [:female, "es"],
  "Jasper Mwangi"   => [:male,   nil],
  "Kira Larsen"     => [:female, "dk"],
  "Liam Murphy"     => [:male,   "ie"]
}

def fetch_portrait(gender:, nat:)
  params = ["gender=#{gender}", "inc=picture"]
  params << "nat=#{nat}" if nat
  api_url = URI("https://randomuser.me/api/?#{params.join('&')}")
  json = Net::HTTP.get(api_url)
  pic_url = URI(JSON.parse(json).dig("results", 0, "picture", "large"))
  Net::HTTP.get_response(pic_url).body
end

count = 0
CSV.foreach(File.join(ROOT, "students.csv"), headers: true) do |row|
  name  = row["name"].to_s.strip
  fname = row["photo"].to_s.strip
  next if name.empty? || fname.empty?

  gender, nat = HINTS[name] || [:female, nil]
  print "  #{name.ljust(20)} (#{gender}#{nat ? ", #{nat}" : ''}) → #{fname} ... "

  3.times do |attempt|
    begin
      File.binwrite(File.join(PHOTOS, fname), fetch_portrait(gender: gender, nat: nat))
      puts "ok"
      count += 1
      break
    rescue => e
      puts "retry (#{e.message})"
      sleep 1
      raise if attempt == 2
    end
  end
  sleep 0.3
end

puts "\nWrote #{count} portraits to #{PHOTOS}"
