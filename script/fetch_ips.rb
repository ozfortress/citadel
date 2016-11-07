user = User.find(ARGV[0].to_i)

ips = Ahoy::Event.select('DISTINCT(ip)').reorder(:ip).where(user: user).map(&:ip)

ips.each do |ip|
  puts ip
end

puts 'Possible Alts:'

ips.each do |ip|
  alt_events = Ahoy::Event.select('DISTINCT(user_id)')
                          .reorder(:user_id)
                          .where(ip: ip)
                          .where.not(user: user)
                          .includes(:user)

  alt_events.map(&:user).each do |alt|
    puts "#{alt.name}, ip: #{ip}, https://warzone.ozfortress.com/users/#{alt.id}"
  end
end
