class Api::V1::BaseController < ActionController::Base
  respond_to :json

  before_filter :skip_trackable
  before_filter :set_access
  before_filter :authenticate_user_by_token_or_user_token!, except: :wrong_url

  rescue_from Errors::ParamsRequired do |e|
    render json: { message: I18n.t("api.errors.common.params_required", param_names: e.param_names.join(', ')) }, status: 400
  end

  rescue_from Errors::NotFound do |e|
    render json: { message: I18n.t("api.errors.common.not_found", model_name: e.classname) }, status: 404
  end

  def wrong_url
    render status: 404, json: { message: 'Url doesn\'t exist' }
  end

  private

    def check_required_params(*param_names)
      not_specified_params = param_names.select { |n| params[n].blank? }
      raise ::Errors::ParamsRequired.new(not_specified_params) if not_specified_params.present?
    end

    def set_access
      response.headers["Access-Control-Allow-Origin"] = "*"
    end

    def skip_trackable
      request.env['devise.skip_trackable'] = true
    end

    def authenticate_user_by_token_or_user_token!
      user = nil
      token = params[:user_token]

      if token.present?
        user = User.where(authentication_token: token).first

        if user.blank?
          user_token = UserToken.active.where(token: token).first
          if user_token.present?
            user = user_token.user
            user_token.update_column(:times_used, user_token.times_used + 1)
          end
        end
      end

      if user
        sign_in user, store: false
      else
        render status: 401, json: { message: "Wrong or expired authorization token" }
        return
      end
    end

    def authenticate_user_by_token!
      token = params[:user_token].present?
      user = token && User.find_by_authentication_token(params[:user_token])

      if user
        sign_in user, store: false
      else
        render status: 401, json: { message: "Wrong or expired authorization token" }
        return
      end
    end
end
