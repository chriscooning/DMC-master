class RemoveAllEventsForDeletedAssets < ActiveRecord::Migration
  def change
    Event.find_each do |ev|
      next if ev.target
      ev.delete
    end
  end
end
