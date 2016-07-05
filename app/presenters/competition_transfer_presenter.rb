class CompetitionTransferPresenter < ActionPresenter::Base
  presents :transfer

  def transfer_message
    if transfer.is_joining?
      "pending transfer to '#{present(transfer.roster).link}'".html_safe
    else
      "pending transfer out of '#{present(transfer.roster).link}'".html_safe
    end
  end
end
