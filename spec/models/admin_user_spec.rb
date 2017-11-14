require 'spec_helper'

describe AdminUser do
  it { should validate_presence_of :email }

  context "#password_expired?" do
    it "expired for newly created user" do
      user = create(:admin_user)
      expect(user.password_expired?).to be_false
    end

    it "true for expired password" do
      user = create(:admin_user)
      user.update_column(:password_expire_at, 1.day.ago)

      expect(user.password_expired?).to be_true
    end

    it "false after password renovation" do
      user = create(:admin_user, password_expire_at: 1.day.ago)
      user.password = user.password_confirmation = 'Aha-Aha#5'
      expect(user.save).to be_true
      expect(user.password_expired?).to be_false
    end
  end
end
