class CallbacksController < ApplicationController
  skip_before_filter :verify_authenticity_token
  skip_before_filter :http_authenticate

  def robot
    handler.process_robot_ping(params)
    render text: 'OK'
  end

  private

    def handler
      @handler ||= VideoHandler.new
    end
end