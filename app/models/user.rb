class User < ActiveRecord::Base
  devise :rememberable, :timeoutable, :trackable,
         :omniauthable, :omniauth_providers => [:steam]

  validates :name, presence: true, uniqueness: true, length: { in: 1..64 }
  validates :steam_id, presence: true, uniqueness: true,
                       numericality: { greater_than: 0 }

  def steam_profile_url
    "http://steamcommunity.com/profiles/#{steam_id}"
  end
end
