#!/usr/bin/env ruby
# Generates one SVG avatar per row in students.csv.
require "csv"
require "fileutils"
require "digest"

ROOT = File.expand_path("..", __FILE__)
PHOTOS = File.join(ROOT, "photos")
FileUtils.mkdir_p(PHOTOS)

PALETTES = [
  %w[#a78bfa #2a2640], %w[#7ee2a8 #1a3528], %w[#ff8b8b #351a1a],
  %w[#fcd34d #3a3018], %w[#60a5fa #1a2638], %w[#f472b6 #3a1c2c],
  %w[#34d399 #143028], %w[#c084fc #2a1f3a], %w[#fb923c #3a2418],
  %w[#22d3ee #102f33], %w[#e879f9 #2f1932], %w[#a3e635 #1f2a14]
]

CSV.foreach(File.join(ROOT, "students.csv"), headers: true) do |row|
  name  = row["name"]
  fname = row["photo"]
  next if name.to_s.strip.empty? || fname.to_s.strip.empty?

  initials = name.split(/\s+/).first(2).map { |w| w[0] }.join.upcase
  idx = Digest::MD5.hexdigest(name).to_i(16) % PALETTES.length
  fg, bg = PALETTES[idx]

  svg = <<~SVG
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 280 280" width="280" height="280">
      <defs>
        <linearGradient id="g" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0" stop-color="#{bg}"/>
          <stop offset="1" stop-color="#0f0f15"/>
        </linearGradient>
      </defs>
      <rect width="280" height="280" fill="url(#g)"/>
      <circle cx="140" cy="115" r="46" fill="#{fg}" opacity="0.92"/>
      <path d="M40 250 C 50 190, 230 190, 240 250 Z" fill="#{fg}" opacity="0.85"/>
      <text x="140" y="128" text-anchor="middle" font-family="-apple-system,BlinkMacSystemFont,Segoe UI,Roboto,sans-serif"
            font-size="44" font-weight="700" fill="#0f0f15">#{initials}</text>
    </svg>
  SVG

  File.write(File.join(PHOTOS, fname), svg)
end

puts "Wrote #{Dir[File.join(PHOTOS, "*.svg")].length} avatars to #{PHOTOS}"
