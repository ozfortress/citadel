# List of steam ids to exclude from medals
VAC = [].freeze

league = League.find(ARGV.first.to_i)

def dump_roster(roster)
  roster.users.find_each do |user|
    puts user.steam_id unless VAC.include?(user.steam_id)
  end
end

league.divisions.each do |division|
  rosters = division.rosters_sorted

  dump_roster rosters.first
  puts
  dump_roster rosters.second
  puts
  dump_roster rosters.third
  puts
  rosters[3..rosters.length].each { |roster| dump_roster roster }
  puts
end
