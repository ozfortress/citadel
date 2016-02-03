require 'scanf'

module SteamId
  module_function

  UNIVERSE_0_TYPE_PUBLIC = 76_561_197_960_265_728

  def to_str(id)
    account_higher = id - UNIVERSE_0_TYPE_PUBLIC
    account_lower = id % 2
    account_higher = (account_higher - account_lower) / 2
    "STEAM_0:#{account_lower}:#{account_higher}"
  end

  def from_str(string)
    account_lower, account_higher = string.scanf('STEAM_0:%d:%d')
    account_lower + account_higher * 2 + UNIVERSE_0_TYPE_PUBLIC
  end
end
