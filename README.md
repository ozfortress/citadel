# Citadel

[![Build Status](https://travis-ci.org/ozfortress/citadel.png)](https://travis-ci.org/ozfortress/citadel)
[![Code Climate](https://codeclimate.com/github/ozfortress/citadel/badges/gpa.svg)](https://codeclimate.com/github/ozfortress/citadel)

## Dependencies

You will need:

* Ruby 2.2
* Bundler
* Postgres (configured in `config/database.yml`)

To install ruby gems for this project, run:

```bash
bundle install
```

To configure secrets for development, use `config/secrets.local.yml`. Example at
`config/secrets.local.yml.example`.

## Tests

This project uses `rspec`, `rubocop`, `haml-lint` and `rails-best-practices` for
testing and linting.

Run `rake test` to run them all.
