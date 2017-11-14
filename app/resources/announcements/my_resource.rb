class Announcements::MyResource < Announcements::BaseResource
  resource :announcement
  accessible_attributes :title, :text

  private

    # any use can view announcements - it's part of portal
    # user should have 'edit account' permission to be able manage it
    def authorize_resource!(action, resource)
      return true if action.to_s == 'read_all' || action.to_s == 'read'
      # all actions with
      authorization_service.authorize!('edit', account)
    end

    def authorization_service
      Authorizers::Backend.new(account: account, accessor: accessor)
    end
end
