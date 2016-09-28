user = User.find(ARGV[0].to_i)

events = Ahoy::Event.where(user: user).reorder(nil)

events.uniq.pluck(:ip).each do |ip|
  puts ip
end
