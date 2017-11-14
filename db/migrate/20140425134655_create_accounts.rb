class CreateAccounts < ActiveRecord::Migration
  def up
    options = {
      force: Rails.env.development?
    }
    unless ActiveRecord::Base.connection.column_exists?(:users, :account_id)
      add_column :users, :account_id, :integer
    end

    create_table :accounts, options do |t|
      t.references "owner"
      t.text     "about"
      t.string   "subdomain"
      t.boolean  "allow_subdomain_indexing",         default: true
      t.text     "theme"
      t.text     "welcome_message"
      t.text     "restrictions_message"
      t.string   "landing_title"
      t.string   "copyrights"
      t.string   "authentication_token"
      t.datetime "authentication_token_expires_at"
      t.string   "s3_hash"
      t.string   "logo_file_name"
      t.string   "logo_content_type"
      t.integer  "logo_file_size"
      t.datetime "logo_updated_at"
      t.string   "logo_text"
      t.string   "logo_url"
      t.integer  "logo_height"
      t.integer  "logo_width"
      t.string   "portal_header_image_file_name"
      t.string   "portal_header_image_content_type"
      t.integer  "portal_header_image_file_size"
      t.datetime "portal_header_image_updated_at"

      t.timestamps
    end

    create_accounts_and_owners
  end

  def down
    # not-reversible
    drop_table :accounts

    if ActiveRecord::Base.connection.column_exists?(:users, :account_id)
      remove_column :users, :account_id
    end
  end

  private

  def create_accounts_and_owners
    Account.reset_column_information
    User.reset_column_information

    User.all.each do |user|
      say_with_time("create account for '#{user.full_name}' with '#{user.subdomain}'") do 
        find_or_update_account_and_owner(user)
      end
    end
  end

  def find_or_update_account_and_owner(user)
    account = Account.where(owner_id: user.id).first_or_initialize
    account.assign_attributes(user.attributes.slice(*account_fields))
    if user.theme.is_a?(Hash)
      account.theme = user.theme
    else
      account.theme = YAML.load(user.theme) rescue {}
    end
    account.save(validate: false)

    user.update_attributes(account_id: account.id)

    account
  end

  def account_fields
    @account_fields ||= begin
      result = Account.columns.map(&:name).map(&:to_s)
      result.delete('id')
      result.delete('theme')
      result
    end
  end
end
