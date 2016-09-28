# rubocop:disable Style/NumericLiterals
VAC = [76561198044298308].freeze
# rubocop:enable Style/NumericLiterals

league = League.find(1)

def dump_roster(roster)
  roster.player_users.each do |user|
    puts user.steam_id unless VAC.include?(user.steam_id)
  end
end

league.divisions.each do |division|
  rosters = division.active_rosters.sort_by(&:sort_keys)

  dump_roster rosters.first
  puts
  dump_roster rosters.second
  puts
  dump_roster rosters.third
  puts
  rosters[3..rosters.length].map { |roster| dump_roster roster }
  puts
end
