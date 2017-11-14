class SubUsers::BaseResource < Cyrax::Resource
  decorator SubUsers::BaseDecorator

  resource :user, class_name: "User"

  def resource_scope
    account.users.where("users.id != :owner_id", owner_id: account.owner.id)
  end

  private
    def account
      options[:account]
    end

    def respond_with(result, options = {})
      options[:account] ||= account
      super(result, options)
    end

    def authorize_resource!(action, resource)
      if action.to_s == 'read' || action.to_s == 'read_all'
        authorization_service.authorize!(:view_subaccounts, account)
      else
        authorization_service.authorize!(:edit_subaccounts, account)
      end
    end

    def authorization_service
      Authorizers::Backend.new(account: account, accessor: accessor)
    end

    def invite
      @invite ||= begin
        if params[:invitation_request].present?
          InvitationRequest.where(id: params[:invitation_request]).first
        end
      end
    end
end
