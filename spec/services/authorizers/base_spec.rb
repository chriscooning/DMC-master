require 'spec_helper'

describe Authorizers::Base do
  context  "#authorize!" do
    let(:account)   { create(:account) }
    let(:owner)     { create(:user).tap { |owner| account.owner = owner; account.save }}
    let(:resource)  { create(:gallery, account_id: account.id) }

    context "common" do
      let(:subject) { Authorizers::Base.new(accessor: build(:user)) }
      it "should raise error if account nil" do
        expect {
          subject.authorize!('read', @resource)
        }.to raise_error(Errors::AuthorizationRequired)
      end

      it "should raise error if resource nil" do
        expect {
          subject.authorize!('read', nil)
        }.to raise_error(Errors::AuthorizationRequired)
      end

      it "should raise if accessor nil" do
        expect {
          subject.authorize!('read', @resource)
        }.to raise_error(Errors::AuthorizationRequired)
      end
    end

    context 'owner of account' do
      let(:subject) { Authorizers::Base.new(account: account, accessor: owner) }

      it "can read all resources" do
        expect(subject.authorize!(:read_all, Gallery)).to eq(true)
      end

      it "can read resource" do
        expect(subject.authorize!(:read, resource)).to eq(true)
      end

      it "can build resource" do
        expect(subject.authorize!(:build, resource)).to eq(true)
      end

      it "can create resource" do
        expect(subject.authorize!(:create, resource)).to eq(true)
      end

      it "can update resource" do
        expect(subject.authorize!(:update, resource)).to eq(true)
      end

      it "can destroy resource" do
        expect(subject.authorize!(:destroy, resource)).to eq(true)
      end
    end

    context "user" do
      def subject(user)
        Authorizers::Base.new(account: account, accessor: user)
      end

      def grant_permission(user, action, resource)
        permission = account.permissions.where(action: action.to_s, resource: resource).first_or_create
        user.permissions << permission
      end

      let(:user) { create(:user).tap {|new_user| new_user.primary_account = account}}

      it "should have read permission to read" do
        pending 'depends from show_visible_items_for_all setting'
        expect {
          subject(user).authorize!(:read, resource)
        }.to raise_error(Errors::AuthorizationRequired)

        grant_permission(user, :read, resource)
        expect(subject(user).authorize!(:read, resource)).to eq(true)
      end

      it "should have edit permission to build" do
        expect {
          subject(user).authorize!(:build, resource)
        }.to raise_error(Errors::AuthorizationRequired)

        grant_permission(user, :edit, resource)
        expect(subject(user).authorize!(:build, resource)).to eq(true)
      end

      it "should have create_galleries permission to create" do
        expect {
          subject(user).authorize!(:create, resource)
        }.to raise_error(Errors::AuthorizationRequired)

        grant_permission(user, :create_galleries, account)
        expect(subject(user).authorize!(:create, resource)).to eq(true)
      end

      it "should have edit permission to update" do
        expect {
          subject(user).authorize!(:update, resource)
        }.to raise_error(Errors::AuthorizationRequired)

        grant_permission(user, :edit, resource)
        expect(subject(user).authorize!(:update, resource)).to eq(true)
      end

      it "should have edit permission to destroy" do
        expect {
          subject(user).authorize!(:destroy, resource)
        }.to raise_error(Errors::AuthorizationRequired)

        grant_permission(user, :edit, resource)
        expect(subject(user).authorize!(:destroy, resource)).to eq(true)
      end

      it "should not have permissions to read_all" do
        expect {
          subject(user).authorize!(:read_all, resource)
        }.not_to raise_error
      end
    end
  end
end
