def create_asset(title, options = {})
  log "create asset: #{title}" do
    asset =  Asset.new(title: title)
    asset.file = sample_asset_image
    asset.description = LOREM_IPSUM
    asset.folder = options[:folder]
    asset.account = options[:account]
    asset.position = options[:position]
    asset.save!
  end
end

def create_user_assets(email)
  user = User.find_by_email(email)
  account = user.primary_account
  gallery = account.galleries.create(name: "#{user.full_name}'s gallery")
  folder = gallery.folders.create(name: "default")
  log "create assets for #{user.email}: " do
    %w[Twilight Eclipse Sunset Rainbow].each_with_index do |title, i|
      create_asset(title, account: account, folder: folder, position: i + 1)
    end
    puts
  end
end

create_user_assets("user@example.com")
create_user_assets("bruce@lee.com")
