require 'spec_helper'

describe Users::AdminResource do
  context "#create" do
    let(:user_params) {
      { user: attributes_for(:user).merge(skip_confirmation: '1') }
    }
    it "accessor should present" do
      expect {
        Users::AdminResource.new(as: nil, params: user_params).create
      }.to raise_error(RuntimeError)
    end

    it "should authorize only admin users" do
      expect {
        Users::AdminResource.new(as: build(:user), params: user_params).create
      }.to raise_error(RuntimeError)
    end

    it "should create user" do
      subject = Users::AdminResource.new(as: build(:admin_user), params: user_params)
      expect{subject.create}.to change{User.count}.by(1)
    end
    
    it "should return user" do
      subject = Users::AdminResource.new(as: build(:admin_user), params: user_params)
      user = subject.create.result
      expect(user).to be_kind_of(User)
    end
  end

  context "#update" do
    let(:user) { create(:user) }

    it 'should update only permitted user attributes' do
      subject = Users::AdminResource.new(as: build(:admin_user), params: {
        user: {
          id: user.id,
          email: 'my_test_email@example',
          full_name: 'Ivan the terrible',
          password_expired: true
        }})

      result = subject.update.result
      expect(result.email).to eq('my_test_email@example')
      expect(result.full_name).to eq('Ivan the terrible')
      expect(result.email).to be_true
    end
  end
end
