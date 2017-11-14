class Backend::CurrentAccountController < ApplicationController
  before_filter :authenticate_user!

  # update
  def select
    new_account = current_user.accounts.where("lower(subdomain) = ?", params[:id].to_s.downcase).first

    if new_account.present?
      session[:current_account_id] = new_account.id
    end

    redirect_to root_url
  end
end
