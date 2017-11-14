class MediaAccountsController < ApplicationController
  respond_to :html

  def show
    respond_with resource.read
  end

  private

    def resource
      @resource ||= MediaAccounts::BaseResource.new(params: params)
    end
end