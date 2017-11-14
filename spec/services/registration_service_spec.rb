require 'spec_helper'

describe RegistrationService do

  context "#create_with_account" do
    let(:session) { {} }
    let(:user_args) {{ 
      full_name: 'kanderus ordo',
      subdomain: 'mandalor',
      email: 'kanderus.ordo@gmail.com',
      password: 'password',
      password_confirmation: 'password',
      invitation_hash: 'some_valid_or_empty_hash'
    }}

    context "#creation errors" do
      it "can't create user&account without email" do
        params = ActionController::Parameters.new(user: user_args.merge(email: ''))
        result = RegistrationService.new(params, session).create_with_account

        expect(result.persisted?).to be_false
        expect(User.count).to eq(0)
        expect(Account.count).to eq(0)
      end

      it "can't create user&account without password" do
        params = ActionController::Parameters.new(user: user_args.merge(password: ''))
        result = RegistrationService.new(params, session).create_with_account

        expect(result.persisted?).to be_false
        expect(User.count).to eq(0)
        expect(Account.count).to eq(0)
      end

      it "can't create user&account without subdomain" do
        params = ActionController::Parameters.new(user: user_args.merge(subdomain: ''))
        result = RegistrationService.new(params, session).create_with_account

        expect(result.persisted?).to be_false
        expect(User.count).to eq(0)
        expect(Account.count).to eq(0)
      end
    end

    context "#successful creation" do
      let(:resource) do
        params = ActionController::Parameters.new(user: user_args)
        RegistrationService.new(params, session).create_with_account
      end

      it 'returns persisted record' do
        expect(resource.persisted?).to be_true
      end

      it 'creates account with given subdomain' do
        expect(resource.accounts.size).to eq(1)
        expect(resource.accounts.first.subdomain).to eq(user_args[:subdomain])
      end

      it 'makes user owner of account' do
        expect(resource.account_owner?(resource.primary_account)).to be_true
      end
    end
  end
end
