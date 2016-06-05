require 'match_seeder/common'
require 'match_seeder/swiss'
require 'match_seeder/round_robin'

module MatchSeeder
  def seed_round_with(method, options = {})
    seeder = "MatchSeeder::#{method.to_s.camelize}".constantize

    seeder.seed_round_for(self, options)
  end
end
