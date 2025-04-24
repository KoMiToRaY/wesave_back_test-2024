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

  def risk_color_class(score)
    case score
    when 0..2 then "text-green-600"
    when 2..4 then "text-yellow-500"
    when 4..7 then "text-red-600"
    else "text-gray-500"
    end
  end
end