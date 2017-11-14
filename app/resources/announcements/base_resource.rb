class Announcements::BaseResource < Cyrax::Resource
  resource :announcement
  decorator Announcements::BaseDecorator

  def resource_scope
    account.announcements
  end

  def build_collection
    resource_scope.page(params[:page]).per(default_per)
  end

  private

    def default_per
      configatron.pagination.announcements.per
    end

    def account
      options[:account]
    end
end
