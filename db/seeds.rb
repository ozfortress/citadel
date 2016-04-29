# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

tf2 = Game.create(name: 'Team Fortress 2')
tf2_6s = Format.create(game: tf2, name: '6s', description: '6 players click on 6 other players', player_count: 6)
badlands = Map.create(game: tf2, name: 'cp_badlands', description: 'The badlands')
process = Map.create(game: tf2, name: 'cp_process_final', description: 'Best map')

# Import indexes to elasticsearch
User.import force: true
Team.import force: true
Competition.import force: true
