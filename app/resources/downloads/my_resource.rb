class Downloads::MyResource < Cyrax::Resource
  resource :download, class_name: 'Event'
  decorator Downloads::BaseDecorator

  def build_collection
    if params[:target_id].present?
      scope = resource_scope.where(target_id: params[:target_id], target_type: 'Asset')
    else
      scope = resource_scope.select("MAX(subject_id) as subject_id, MAX(subject_type) as subject_type, MAX(target_type) as target_type, MAX(created_at) as created_at, target_id, COUNT(*) AS total_count").group('target_id')
    end
    scope.order("created_at DESC").includes(:subject, :target)
    scope = scope.page(params[:page]) unless options[:without_pagination]
    scope
  end

  def resource_scope
    account.related_events.download
  end

  private
    
    def account
      @account ||= options[:account]
    end

    def authorization_service
      Authorizers::Backend.new(account: account, accessor: accessor)
    end

    def authorize_resource!(action, resource)
      authorization_service.authorize!(:view_analytics, resource)
    end
end
