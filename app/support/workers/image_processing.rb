class Workers::ImageProcessing < Workers::Base
  sidekiq_options queue: :high

  def perform(id)
    asset = Asset.find(id)
    return if !asset.image? || asset.processed?
    asset.file.reprocess!(:small, :medium, :large)
    asset.update_column :processed, true
  end
end