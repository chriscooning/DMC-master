class Workers::VideoProcessor < Workers::Base
  sidekiq_options queue: :high

  def perform(id)
    video = Asset.find(id)
    VideoHandler.new.process(video)
  end
end