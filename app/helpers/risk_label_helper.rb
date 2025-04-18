module RiskLabelHelper
  def risk_label(score)
    return "Aucun risque" if score.to_f.zero?

    case score
    when 0..2
      "Faible"
    when 2.1..4
      "Modéré"
    when 4.1..5.5
      "Élevé"
    else
      "Très élevé"
    end
  end
end