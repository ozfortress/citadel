# Citadel

[![Build Status](https://travis-ci.org/ozfortress/citadel.svg?branch=master)](https://travis-ci.org/ozfortress/citadel)
[![Coverage Status](https://coveralls.io/repos/github/ozfortress/citadel/badge.svg?branch=master)](https://coveralls.io/github/ozfortress/citadel?branch=master)
[![Code Climate](https://codeclimate.com/github/ozfortress/citadel/badges/gpa.svg)](https://codeclimate.com/github/ozfortress/citadel)
[![Dependency Status](https://gemnasium.com/ozfortress/citadel.svg)](https://gemnasium.com/ozfortress/citadel)

Open Source, Web-based league system designed for games such as Team Fortress 2.

## Goals

* Highly configurable league system
* Full automation for regular tasks (league management/setup, etc.)
* Fine grained permission system

## Dependencies

You will need:

* Ruby 2.3.1
* Bundler
* Postgres (configured in `config/database.yml`)
* ImageMagick

To install all other ruby dependencies, run:

```bash
bundle install
```

To configure secrets (ie. steam API key) for development, use
`config/secrets.local.yml`. Example at `config/secrets.local.yml.example`.
Or put the secrets in environment variables (`SECRET_KEY_BASE`, `STEAM_API_KEY`)

## Tests

This project uses `rspec`, `rubocop`, `haml-lint` and `rails-best-practices` for
testing and linting.

All of these can be run in one command with rake

```bash
rake
# or
rake test
```
