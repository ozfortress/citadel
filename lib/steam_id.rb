require 'scanf'

module SteamId
  extend self

  def to_str(id)
    account_higher = id - 76561197960265728
    account_lower = id % 2
    account_higher = (account_higher - account_lower) / 2
    "STEAM_0:#{account_lower}:#{account_higher}"
  end

  def from_str(string)
    universe, account_lower, account_higher = string.scanf("STEAM_%d:%d:%d")
    account_lower + account_higher * 2 + 76561197960265728
  end
end
