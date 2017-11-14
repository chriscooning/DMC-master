class RegistrationService
  attr_accessor :params, :session

  def initialize(params, session)
    @params  = params.require(:user) || {}
    @session = session
  end

  def create_with_account
    user    = build_user
    account = build_account

    if user.valid? && account.valid?
      ActiveRecord::Base.transaction do
        account.save!
        user.save!

        assign_account_owner(account, user)

        account.send(:create_permissions)
      end
    else
      account.valid? # get errors from account.
      account.errors.each do |field, message|
        user.errors.add(field, message)
      end
    end

    user
  end

  private

  def invitation_hash
    params[:invitation_hash]
  end

  def user_attributes
    @user_attributes ||= params.permit(*%w{full_name email password password_confirmation})
  end

  def account_attributes
    @accont_attributes ||= params.permit(*%w{subdomain})
  end

  def build_user
    # devise uses User.new_with_session, which equals to User.new by default
    result = User.new(user_attributes)
    result.invitation_hash = invitation_hash
    result
  end

  def build_account
    Account.new(account_attributes)
  end

  def assign_account_owner(account, owner)
    relation = AccountUser.where(account_id: account.id, user_id: owner.id).first_or_initialize

    relation.owner = true
    relation.primary = true

    relation.save
  end
end
