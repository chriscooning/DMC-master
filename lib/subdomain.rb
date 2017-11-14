class Subdomain
  IGNORE_SUBDOMAINS = %w[www api]
  IGNORE_DOMAINS = %w[dmc_wayne.t.proxylocal.com]

  def self.matches?(request)
    return false if request.domain.blank?
    is_custom_domain = !ignore_domains.include?(request.host)
    is_custom_subdomain = !IGNORE_SUBDOMAINS.include?(request.subdomain)
    request.subdomain.present? && is_custom_domain && is_custom_subdomain
  end

  def self.ignore_domains
    IGNORE_DOMAINS + [configatron.domain]
  end
end