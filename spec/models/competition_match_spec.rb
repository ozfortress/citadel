require 'rails_helper'
require 'support/shoulda'
require 'support/factory_girl'

describe CompetitionMatch do
  before { create(:competition_match) }

  it { should belong_to(:home_team).class_name('CompetitionRoster') }
  it { should belong_to(:away_team).class_name('CompetitionRoster') }
  it { should have_many(:sets).class_name('CompetitionSet') }

  it { should validate_presence_of(:home_team) }

  it do
    should define_enum_for(:status).with([:pending, :submitted_by_home_team,
                                          :submitted_by_away_team, :confirmed])
  end

  it do
    should define_enum_for(:forfeit_by).with([:no_forfeit, :home_team_forfeit,
                                              :away_team_forfeit, :mutual_forfeit,
                                              :technical_forfeit])
  end

  it 'should confirm BYE matches' do
    roster = build(:competition_roster)

    expect(CompetitionMatch.new(home_team: roster).status).to eq('confirmed')
  end

  it 'should notify all players of upcoming matches' do
    div = create(:division)
    home_team = create(:competition_roster, division: div)
    away_team = create(:competition_roster, division: div)
    players = home_team.player_users + away_team.player_users
    players.each { |user| user.notifications.destroy_all }

    match = create(:competition_match, home_team: home_team, away_team: away_team)

    (home_team.player_users + away_team.player_users).each do |user|
      expect(user.notifications).to_not be_empty
    end
  end

  it 'should notify all players of a BYE match' do
    home_team = create(:competition_roster)
    home_team.player_users.each { |user| user.notifications.destroy_all }

    match = create(:bye_match, home_team: home_team)

    home_team.player_users.each do |user|
      expect(user.notifications).to_not be_empty
    end
  end
end
