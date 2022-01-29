require 'net/http'
require 'json'

# Checks all users in citadel for VAC bans
# Distinguishing between games is impossible through the API,
# so checks will have to be done manually.

API_KEY = Rails.application.secrets.steam_api_key

def get_bans(steam_ids)
  ids = steam_ids.join(',')
  url = "http://api.steampowered.com/ISteamUser/GetPlayerBans/v1/?key=#{API_KEY}&steamids=#{ids}"
  response = Net::HTTP.get(URI(url))
  json = JSON.parse(response)

  json['players'].select { |player| player['VACBanned'] }
                 .map { |player| player['SteamId'] }
                 .map(&:to_i)
end

User.order(:id).find_in_batches(batch_size: 10) do |users|
  steam_ids = users.map(&:steam_id)
  bans = get_bans(steam_ids)
  bans.each do |steam_id|
    user = User.find_by(steam_id: steam_id)
    puts("#{user.name}: https://ozfortress.com/users/#{user.id}")
  end
end
