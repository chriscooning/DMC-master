class EventTracker
  attr_accessor :accessor

  def initialize(options = {})
    @options = options
    @accessor = options[:as]
  end

  def track(params = {})
    asset = Asset.find(params[:target_id])
    Event.create(subject: accessor, target: asset, target_owner: asset.account, name: params[:name])
  end
end
