require 'scanf'

# Makes sense if you understand ids :reek:UncommunicativeMethodName
module SteamId
  module_function

  UNIVERSE_0_TYPE_PUBLIC = 76_561_197_960_265_728

  def valid_32?(string)
    string =~ /^STEAM_0:[0-9]+:[0-9]+$/
  end

  def valid_64?(string)
    Integer(string)
  rescue ArgumentError
    false
  end

  def valid_id3?(string)
    string =~ /^U:1:[0-9]+$/
  end

  def to_32(value)
    value = to_64(value)

    from_64_to_32(value) if value
  end

  def to_64(value)
    if valid_32?(value)
      from_32_to_64(value)

    elsif valid_id3?(value)
      from_id3_to_64(value)

    elsif valid_64?(value)
      value.to_i
    end
  end

  def to_id3(value)
    value = to_64(value)

    from_64_to_id3(value) if value
  end

  def from_32_to_64(value)
    account_lower, account_higher = value.scanf('STEAM_0:%d:%d')
    account_lower + account_higher * 2 + UNIVERSE_0_TYPE_PUBLIC
  end

  def from_id3_to_64(value)
    offset, = value.scanf('U:1:%d')
    UNIVERSE_0_TYPE_PUBLIC + offset
  end

  def from_64_to_32(value)
    account_higher = value - UNIVERSE_0_TYPE_PUBLIC
    account_lower = value % 2
    account_higher = (account_higher - account_lower) / 2
    "STEAM_0:#{account_lower}:#{account_higher}"
  end

  def from_64_to_id3(value)
    offset = value - UNIVERSE_0_TYPE_PUBLIC
    "U:1:#{offset}"
  end
end
