# ozfortress.com

## Dependencies

You will need:

* Ruby 2.2
* Bundler
* Postgres (configured in `config/database.yml`)

To install ruby gems for this project, run:

```bash
bundle install
```

To configure secrets for development, use `secrets.local.yml`. Example at
`secrets.local.yml.example`.

## Tests

This project uses `rspec` for tests and `rubocop` for linting.

Run `rake test` for both.
