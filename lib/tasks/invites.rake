namespace :invites do
  desc 'Delete expired team invites'
  task purge_expired: :environment do
    expired = Team::Invite.expired
    if expired.any?
      deleted = expired.delete_all
      puts "Deleted #{deleted} expired team invites. #{Team::Invite.active.count} invites remain active."
    else
      puts "No expired team invites to delete. #{Team::Invite.active.count} invites remain active."
    end
  end
end
