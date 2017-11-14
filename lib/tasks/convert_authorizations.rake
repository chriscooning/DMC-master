namespace "db" do
  namespace "populate" do
    desc "[accounts] add permissiojns for all objects"
    task permissions: :environment do
      Account.all.map{|item| item.send(:create_permissions)}
      Gallery.all.map{|item| item.send(:create_permissions)}
      Folder.all.map{|item| item.send(:create_permissions)}
    end

    desc "[accounts] add sample roles for all accounts"
    task roles: :environment do
      Account.all.each do |account|
        role = account.roles.where(name: "Guest").first_or_create
        role.permissions = account.permissions.where(action: 'read').to_a
        role.save

        role = account.roles.where(name: "Editor").first_or_create
        role.permissions = account.permissions.where(action: %w{edit create_galleries create_folders create_assets}).to_a
        role.save
      end
    end
  end

  namespace "convert" do
    desc "[accounts] convert gallery members to sub-users"
    task gallery_members: :environment do
      GalleryMember.includes(:gallery, :user).all.each do |gallery_member|
        convert_membership_to_permissions(gallery_member.user, gallery_member.gallery, gallery_member.role)
      end
    end

    desc "[accounts] convert invites to sub-users"
    task invites: :environment do
      InvitationRequest.all.each do |invite|
        convert_invite_to_permissions(invite)
      end
    end
  end
end

def convert_membership_to_permissions(user, gallery, role)
  # ensure user joined account
  gallery.account.add_user(user: user, invited: true, primary: false)

  if role.to_s == 'admin'
    give_permissions_on_gallery(user, gallery, {})
  else
    give_permissions_on_gallery(user, gallery, { action: 'read' })
  end
end

def give_permissions_on_gallery(user, gallery, scope = {})
  gallery.permissions.where(scope).each do |permission|
    user.permissions << permission unless user.permissions.include?(permission)
  end

  gallery.folders.each do |folder|
    folder.permissions.where(scope).each do |permission|
      user.permissions << permission unless user.permissions.include?(permission)
    end
  end
end

def convert_invite_to_permissions(invite)
  gallery = invite.gallery

  user = create_user_from_invite(invite)

  if invite.role == 'admin'
    user.permissions << gallery.permissions
  elsif invite.role == 'viewer'
    user.permissions << gallery.permissions.where(action: 'read')
  end
rescue Exception => e
  puts "can't convert invite #{ invite.inspect } to sub-user with permission" 
end

def create_user_from_invite(invite)
  account = invite.gallery.account

  user = User.where(email: invite.email).first_or_initialize
  if user.persisted?
    account.add_user(user: user, primary: false, invited: true)
  else
    user.password = user.password_confirmation = SecureRandom.hex
    user.full_name = invite.email.split('@').first
    user.skip_confirmation!

    user.save(validate: false)

    account.add_user(user: user, primary: true, invited: false)

    send_new_user_info(user)
  end

  invite.delete

  user
end

def send_new_user_info(user)
  raw, enc = Devise.token_generator.generate(User, :reset_password_token)

  user.reset_password_token   = enc 
  user.reset_password_sent_at = Time.now.utc
  user.save(:validate => false)

  user.send(:send_devise_notification, :new_user_created, raw, {}) 
end
