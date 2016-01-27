module TeamsHelper
  def format_options
    Format.all.map do |format|
      ["#{format.game.name}: #{format.name}", format.id]
    end
  end

  def teams
    Team.all
  end
end
