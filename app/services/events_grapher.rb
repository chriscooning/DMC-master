class EventsGrapher
  attr_reader :accessor, :account

  def initialize(options = {})
    @accessor = options[:as]
    @account  = options[:account]
  end

  def read(params)
    authorize_resource!(:view_analytics, account)

    scope = account.assets.find(params[:id]).events
    common_request(scope, params)
  end

  def read_all(params = {})
    authorize_resource!(:view_analytics, account)

    scope = account.related_events
    common_request(scope, params)
  end

  private

    def common_request(base, params)
      from = params[:from].present? ? Date.strptime(params[:from], '%m/%d/%Y') : Date.today - 1.month
      to = params[:to].present? ? Date.strptime(params[:to], '%m/%d/%Y') : Date.today
      scope = base.where(created_at: from..to).group("DATE(created_at)")
      downloads = scope.where(name: "download").count

      (from..to).map do |date|
        {
          date: date,
          downloads: downloads[date].to_i
        }
      end
    end

    def authorization_service
      Authorizers::Base.new(account: account, accessor: accessor)
    end

    def authorize_resource!(action, resource)
      authorization_service.authorize!(action, resource)
    end
end
