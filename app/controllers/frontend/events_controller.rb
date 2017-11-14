class Frontend::EventsController < Frontend::BaseController

  def create
    service.track(params[:event])
    render text: 'OK'
  end

  private

    def service
      @service ||= EventTracker.new(as: current_user)
    end
end
