class StaticController < ApplicationController
  skip_before_filter :load_user

  rescue_from ActionView::MissingTemplate do |exception|
    if exception.message =~ %r{Missing template}
      raise ActionController::RoutingError, "No such page: #{params[:page]}"
    else
      raise exception
    end
  end

  def show
    render "static/#{current_page}"
  end

  private

    def current_page
      path = Pathname.new "/#{params[:page]}"
      path.cleanpath.to_s[1..-1]
    end
end