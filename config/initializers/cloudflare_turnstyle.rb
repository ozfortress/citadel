RailsCloudflareTurnstile.configure do |c|
  c.enabled = Rails.env.production?
  c.mock_enabled = !Rails.env.production? && !Rails.env.test?
  c.site_key = Rails.application.credentials.cloudflare_turnstyle_site_key
  c.secret_key = Rails.application.credentials.cloudflare_turnstyle_secret_key
  c.fail_open = true
  c.theme = :light
end
