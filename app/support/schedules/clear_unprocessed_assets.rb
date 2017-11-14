class Schedules::ClearUnprocessedAssets
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { daily.hour_of_day(12) }

  def perform
    Asset.where(
      'processed = ? AND created_at <= ?', false, DateTime.now - 1.day
    ).with_deleted.find_each do |asset|
      if asset.account
        asset.destroy
      else
        asset.delete
      end
    end
  end
end
