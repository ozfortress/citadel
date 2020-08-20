raise 'Wrong number of arguments' unless ARGV.length >= 2 && ARGV.length <= 3

steam_id = SteamId.to_64(ARGV[0])
raise 'Invalid steam id' unless steam_id

username = ARGV[1]
raise 'Empty username' if username.empty?

terminated_at = Time.zone.now + ActiveSupport::Duration.parse(ARGV[2]) if ARGV.length == 3

# Find the user or create them if they don't exist
u = User.find_by(steam_id: steam_id)
puts 'Banning existing user' if u

u ||= User.create!(steam_id: steam_id, name: username)

# Ban from everything
u.ban(:use, :users, terminated_at: terminated_at)
u.ban(:use, :teams, terminated_at: terminated_at)
u.ban(:use, :leagues, terminated_at: terminated_at)
u.ban(:use, :forums, terminated_at: terminated_at)

puts "Banned user #{u.id}"
