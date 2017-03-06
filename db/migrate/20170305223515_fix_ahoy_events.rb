class FixAhoyEvents < ActiveRecord::Migration[5.0]
  def change
    reversible do |dir|
      dir.up do
        Ahoy::Event.where(visit: nil).find_each do |event|
          event.visit = Visit.create!(ip: event.ip, user_id: event.user_id)
          event.name  = "#{event.method} #{event.uri}"
          event.save!
        end
      end
    end

    remove_column :ahoy_events, :user_id, :integer
    remove_column :ahoy_events, :ip,      :string
    remove_column :ahoy_events, :method,  :string
    remove_column :ahoy_events, :uri,     :string

    add_index :visits, :api_key_id
    add_index :visits, :ip
  end
end
