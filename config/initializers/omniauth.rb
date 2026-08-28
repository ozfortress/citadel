require 'openid/fetchers'

# Set CA certificate file path based on OS
if Rails.env.development?
  # macOS with Homebrew
  if File.exist?('/opt/homebrew/etc/ca-certificates/cert.pem')
    OpenID.fetcher.ca_file = '/opt/homebrew/etc/ca-certificates/cert.pem'
  # macOS with MacPorts or other package managers
  elsif File.exist?('/opt/local/etc/openssl/cert.pem')
    OpenID.fetcher.ca_file = '/opt/local/etc/openssl/cert.pem'
  # macOS system default
  elsif File.exist?('/etc/ssl/cert.pem')
    OpenID.fetcher.ca_file = '/etc/ssl/cert.pem'
  # Linux/Ubuntu
  elsif File.exist?('/etc/ssl/certs/ca-certificates.crt')
    OpenID.fetcher.ca_file = '/etc/ssl/certs/ca-certificates.crt'
  else
    Rails.logger.warn 'No CA certificate file found, Steam authentication may fail'
  end
else
  # Production environments (Linux)
  OpenID.fetcher.ca_file = '/etc/ssl/certs/ca-certificates.crt'
end
