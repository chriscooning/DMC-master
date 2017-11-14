class Schedules::ClearDeletedEntities
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { daily.hour_of_day(12) }

  def perform
    asset_ids = Asset.deleted.where('deleted_at < ?', deletion_period).pluck(:id)
    asset_ids.each { |id| Workers::AssetClearance.enqueue(id) }
    Folder.deleted.where('deleted_at < ?', deletion_period).destroy_all
    Gallery.deleted.where('deleted_at < ?', deletion_period).destroy_all
  end

  private

    def deletion_period
      DateTime.now - configatron.clear_deleted_entities_after
    end
end