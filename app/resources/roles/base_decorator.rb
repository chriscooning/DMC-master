class Roles::BaseDecorator < Cyrax::Decorator
  def as_json(options = {})
    only = [:name, :description]
    resource.as_json(methods: methods, only: only)
  end

  def available_permissions
    self.account.permissions.includes(:resource).order('resource_id asc')
  end

  def available_permissions_options
    available_permissions.to_a.map do |p|
      [p.id, p.description]
    end
  end
end
