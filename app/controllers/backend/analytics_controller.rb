class Backend::AnalyticsController < Backend::BaseController
  def index
    render json: service.read_all(params)
  end

  def show
    render json: service.read(params)
  end

  private

    def service
      @service ||= EventsGrapher.new(as: current_user, account: current_account)
    end
end
