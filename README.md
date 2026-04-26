# TutorCards

Rails 8.1 app for learning the names of people in a tutor group. Import a CSV
of `name,photo` rows (and the photo files themselves), then study with a
Leitner-box spaced-repetition loop, Anki-style.

- **Port:** 8087 (`http://192.168.122.242:8087/`)
- **Database:** SQLite (`storage/`)
- **Photos:** uploaded files land in `storage/photos/`, served via `/photos/:filename`

## Run

```
bundle install
bin/rails db:migrate db:seed       # seed loads db/sample/students.csv + photos
bundle exec rails server -b 0.0.0.0 -p 8087
```

## Leitner intervals

| Box | Next due after |
|----:|----------------|
| 1   | every session  |
| 2   | 1 day          |
| 3   | 3 days         |
| 4   | 7 days         |
| 5   | 14 days        |

"Got it" promotes a card one box; "Missed" sends it back to Box 1.

## CSV format

```
name,photo
Alice Chen,alice.svg
Bilal Ahmed,bilal.svg
```

The `photo` value is the filename of an image you upload alongside the CSV in
the import form. A working sample lives in `db/sample/`.

## Sample data

Run `ruby db/sample/generate_photos.rb` to regenerate the 12 SVG avatars from
the names in `db/sample/students.csv`.
