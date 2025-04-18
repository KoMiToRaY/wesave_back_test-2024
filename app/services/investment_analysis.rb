# app/services/investment_analysis.rb
class InvestmentAnalysis
  def self.call(customer)
    new(customer).perform
  end

  def initialize(customer)
    @customer = customer
    @portfolios = customer.portfolios.includes(portfolio_investments: :investment)
  end

  def perform
    {
      portfolios: @portfolios.map { |p| analyze_portfolio(p) },
      global: analyze_global_risk
    }
  end

  private

  def analyze_portfolio(portfolio)
    lines = portfolio.portfolio_investments
    total = lines.sum(&:amount)

    {
      id: portfolio.id,
      label: portfolio.label,
      risk: average_risk(lines, total),
      allocation: allocation_by_type(lines, total)
    }
  end

  private

  # Calcul du risque moyen du portefeuille via une moyenne pondérée :
  # Chaque investissement est pondéré par le montant investi pour refléter son importance relative.
  # Formule : (Σ montant_i × SRI_i) / montant_total
  # Référence : https://blog.nalo.fr/lexique/moyenne-ponderee/
  def average_risk(lines, total)
    return 0 if total.zero?

    weighted_sum = lines.sum do |line|
      line.amount.to_f * line.investment.sri.to_f
    end

    (weighted_sum / total).round(2)
  end

  def allocation_by_type(lines, total)
    return {} if total.zero?

    lines
      .group_by { |line| line.investment.investment_type }
      .transform_values do |group|
        ((group.sum(&:amount).to_f / total) * 100).round(2)
      end
  end

  # Même formule que pour average_risk mais appliqué globalement sur toutes les lignes d’investissement du client.
  # Référence : https://blog.nalo.fr/lexique/moyenne-ponderee/
  def analyze_global_risk
    lines = @portfolios.flat_map(&:portfolio_investments)
    total = lines.sum(&:amount)

    risk = if total.zero?
      0
    else
      lines.sum { |line| line.amount.to_f * line.investment.sri.to_f } / total
    end

    {
      risk: risk.round(2),
      allocation: allocation_by_type(lines, total)
    }
  end
end
