class MigrateDownloadsToEvents < ActiveRecord::Migration
  def change
    Download.find_each do |d|
      Event.create(
        name: 'download',
        subject: d.subject,
        target: d.asset,
        target_owner: d.owner,
        created_at: d.created_at,
        updated_at: d.updated_at
      )
    end
  end
end
