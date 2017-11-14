class Workers::AudioProcessor < Workers::Base
  sidekiq_options queue: :high

  def perform(id)
    asset = Asset.find(id)
    return if !asset.audio? || asset.processed?
    asset.file.reprocess!(:mp3, :ogg)
    #asset.file.reprocess!(:small, :medium)
    asset.update_column :processed, true
  end
end
