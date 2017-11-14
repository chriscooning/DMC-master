class Events::MyResource < Cyrax::Resource
  resource :event
  decorator Events::BaseDecorator

  def resource_scope
    accessor.related_events
  end

  def build_collection
    resource_scope.includes(:subject, :target).page(params[:page]).per(params[:per])
  end
end