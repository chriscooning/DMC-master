class Workers::AssetClearance < Workers::Base
  sidekiq_options queue: :low

  def perform(id)
    asset = Asset.deleted.where(id: id)
    return unless asset.first
    asset.first.destroy!
  end
end