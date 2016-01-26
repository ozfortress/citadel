# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

tf2 = Game.create(name: "Team Fortress 2")
6s = Format.create(game: tf2, name: "6s", description: "6v6", player_count: 6)
