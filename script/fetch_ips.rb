user = User.find(ARGV[0].to_i)

ips = Visit.select('DISTINCT(ip)').reorder(:ip).where(user: user).map(&:ip)

ips.each do |ip|
  puts ip
end

puts 'Possible Alts:'

alt_visits = Visit.select('DISTINCT(user_id)')
                  .reorder(:user_id)
                  .where(ip: ips)
                  .where.not(user: user)
                  .includes(:user)

alt_visits.each do |visit|
  alt = visit.user

  puts "#{alt.name}, ip: #{visit.ip}, https://warzone.ozfortress.com/users/#{alt.id}"
end
