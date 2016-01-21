class User < ActiveRecord::Base
  devise :rememberable, :timeoutable, :trackable,
         :omniauthable, :omniauth_providers => [:steam]
end
