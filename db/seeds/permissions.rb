def create_sample_permissions
  Account.all.each do |account|
    log "create permissions for: #{account.subdomain}" do
      account.permissions.where(account_id: account.id, action: 'view_subaccounts').first_or_create
      account.permissions.where(account_id: account.id, action: 'edit_subaccounts').first_or_create
      account.permissions.where(account_id: account.id, action: 'create_galleries').first_or_create
      account.permissions.where(account_id: account.id, action: 'sort_galleries').first_or_create

      account.galleries.each do |gallery|
        gallery.permissions.where(account_id: account.id, action: 'read').first_or_create
        gallery.permissions.where(account_id: account.id, action: 'edit').first_or_create
        gallery.permissions.where(account_id: account.id, action: 'create_folders').first_or_create
        gallery.permissions.where(account_id: account.id, action: 'sort_folders').first_or_create
      end

      account.folders.each do |folder|
        folder.permissions.where(account_id: account.id, action: 'read').first_or_create
        folder.permissions.where(account_id: account.id, action: 'edit').first_or_create
        folder.permissions.where(account_id: account.id, action: 'create_assets').first_or_create
        folder.permissions.where(account_id: account.id, action: 'update_assets').first_or_create
      end
    end
  end
end

def create_sample_roles
  Account.all.each do |account|
    log "create editor/guest roles for: #{account.subdomain}" do
      role = account.roles.where(name: "Guest").first_or_create
      role.permissions = account.permissions.where(action: 'read').to_a
      role.save

      role = account.roles.where(name: "Editor").first_or_create
      role.permissions = account.permissions.where(action: %w{edit create_galleries create_folders create_assets}).to_a
      role.save
    end
  end
end

create_sample_permissions
create_sample_roles
