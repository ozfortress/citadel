# frozen_string_literal: true

# rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Style/SignalException

# Before running the script change the following constants to what you require
require 'net/http'

HOST = 'http://localhost:3000'
LEAGUE_ID = 6

MATCH_NOTICE_TEMPLATE = "\
Foo
"

ACTIVE_MATCH_NOTICE_TEMPLATE = "\
Bar `%{connect_string}`
"

SSC_API_KEY = 'ABC'
SSC_ENDPOINT = 'http://127.0.0.1:8080/api/v1'

MAX_MATCH_LENGTH = 8

MAP = Map.first

MATCH_PARAMS = {
  round_name:        '#1',
  has_winner:        true,
  rounds_attributes: [{ map: MAP }],
}.freeze

def match_s(match)
  if match.bye?
    "#{match.home_team.name} BYE"
  else
    "#{match.home_team.name} VS #{match.away_team.name}"
  end
end

def match_url(match)
  Rails.application.routes.url_helpers.match_url(match, host: HOST)
end

def strip_rcon(connect_string)
  connect, password, = connect_string.split(';')
  [connect, password].join(';')
end

# Book a server using SSC
def book_server(user)
  query = {
    key:   SSC_API_KEY,
    user:  user,
    hours: MAX_MATCH_LENGTH,
  }
  result = Net::HTTP.post_form(URI.parse(SSC_ENDPOINT + "/bookings/?#{query.to_query}"), {})

  json = JSON.parse result.body
  if result.code != '200'
    puts "Error: Failed booking for #{user}, #{json['statusMessage']}"
    return nil
  end
  json['server']['connect-string']
end

# Unbook a server using SSC
def unbook_server(user)
  query = {
    key: SSC_API_KEY,
  }

  user_encoded = ERB::Util.url_encode user
  uri = URI.parse(SSC_ENDPOINT + "/bookings/#{user_encoded}/?#{query.to_query}")

  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = uri.port == 443
  request = Net::HTTP::Delete.new(uri.to_s)
  result = http.request(request)

  return if result.code == '204'

  json = JSON.parse result.body
  if result.code == '404' && json['statusMessage'] == 'Booking not found'
    puts "Warning: Booking was not found for #{user}, ignoring"
    return
  end

  puts "Error: Failed to unbook for #{user}, #{json['statusMessage']}"
  fail
end

def book_servers
  league = League.find(LEAGUE_ID)

  # Unbook servers for completed matches
  completed_matches = league.matches.confirmed.where.not(script_state: nil)
  puts "Unbooking Servers (#{completed_matches.size})" unless completed_matches.empty?
  completed_matches.find_each do |match|
    user = match.script_state
    unbook_server(user)
    match.update!(script_state: nil)
    puts "Unbooked: #{user} for #{match_s(match)} ; #{match_url(match)}"
  end

  # Book servers for pending matches
  unbooked_matches = league.matches.pending.where(script_state: nil)
  puts "Booking Servers (#{unbooked_matches.size})" unless unbooked_matches.empty?
  unbooked_matches.find_each do |match|
    user = match_s(match).sub(%r{/}, '') # Replace / since they break ssc (vibe.d workaround)
    connect_string = book_server(user)
    unless connect_string
      puts 'Warning: No more available servers, stopping'
      break
    end

    connect_string = strip_rcon connect_string
    notice = format(ACTIVE_MATCH_NOTICE_TEMPLATE, connect_string: connect_string)
    match.update!(script_state: user, notice: notice)
    notify_users(match, 'The server for your match is now available')
    puts "Booked: #{user} for #{match_s(match)} ; #{match_url(match)}"
  end
end

def notify_users(match, message)
  url = match_url(match)
  users = match.home_team.users.union(match.away_team.users)

  users.find_each do |user|
    Users::NotificationService.call(user, message, url)
  end
end

def generate(round)
  league = League.find(LEAGUE_ID)

  # The round should not exist
  if league.matches.round(round).exists?
    puts 'Error, round already exists'
    return
  end

  # There should be no incomplete matches
  pending_matches = league.matches.where.not(status: :confirmed)
  unless pending_matches.empty?
    puts 'Error, the following matches are pending:'
    pending_matches.each do |match|
      puts "#{match_s(match)} ; #{match_url(match)}"
    end
    return
  end

  puts 'Generating Matches'
  league.divisions.each do |division|
    match_params = { round_number: round, notice: MATCH_NOTICE_TEMPLATE }.merge(MATCH_PARAMS)

    invalid = Leagues::Matches::GenerationService.call(division, match_params, :single_elimination, round: round)

    if invalid
      p invalid.errors
      fail
    end

    puts "Created Matches for #{division.name}:"
    division.matches.round(round).find_each do |match|
      puts "#{match_s(match)} ; #{match_url(match)}"
    end
  end
end

fail 'Invalid Arguments' if ARGV.empty?

ActiveRecord::Base.transaction do
  case ARGV[0]
  when 'generate'
    generate(ARGV[1].to_i)
  when 'book'
    book_servers
  else
    fail 'Invalid Command'
  end
end

# rubocop:enable Metrics/MethodLength, Metrics/AbcSize, Style/SignalException
