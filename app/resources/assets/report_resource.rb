class Assets::ReportResource < Cyrax::Resource
  resource :asset
  decorator Assets::ReportDecorator

  def resource_scope
    account.assets.processed.
      joins(:folder => :gallery).
      where(deleted_at: nil).
      where(folders: { deleted_at: nil }).
      where(galleries: { deleted_at: nil })
  end

  def build_collection
    select = Event::EVENT_NAMES.map do |name|
      "(SELECT COUNT(*) FROM events WHERE
          events.target_id = assets.id AND 
          events.target_type = 'Asset' AND 
          events.name = '#{name}'
        ) AS events_#{name}_count"
    end
    select += %w(assets.*)
    scope = resource_scope.select(select.join(', ')).references(:events, :assets)
    scope = scope.page(params[:page]).per(params[:per]) unless options[:without_pagination]
    scope
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
