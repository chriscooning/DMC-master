require 'spec_helper'

describe Schedules::ClearDeletedEntities do
  
  let(:subject) { Schedules::ClearDeletedEntities.new }
  before do 
    10.times{ create(:deleted_asset) }
    5.times{ create(:deleted_folder) }
    2.times{ create(:deleted_gallery) }
  end


  describe "N days after entities deletion" do
    before do
      Timecop.travel(DateTime.now + configatron.clear_deleted_entities_after)
      subject.perform
    end

    it "should delete all assets" do
      assert_equal Asset.with_deleted.count, 0
    end

    it "should delete all folders" do
      assert_equal Folder.with_deleted.count, 0
    end 

    it "should delete all galleries" do
      assert_equal Gallery.with_deleted.count, 0
    end
  end
end