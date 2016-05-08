module Transfers
  extend ActiveSupport::Concern

  def player_transfers(tfers = nil, unique_for = 'user_id')
    tfers ||= transfers
    tb_name = tfers.proxy_association.aliased_table_name
    tfers.select("DISTINCT ON(#{tb_name}.#{unique_for}) #{tb_name}.id")
         .reorder(unique_for, created_at: :desc)
  end
end
