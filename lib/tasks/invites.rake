namespace :invites do
  desc 'Delete expired team invites'
  task purge_expired: :environment do
    deleted = Team::Invite.expired.delete_all
    if deleted.positive?
      puts "Deleted #{deleted} expired team invites. #{Team::Invite.count} invites remain."
    else
      puts "No expired team invites to delete. #{Team::Invite.count} invites remain."
    end
  end
end
