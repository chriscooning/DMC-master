class ConvertGalleryMembersToAccountUsers < ActiveRecord::Migration
  def up
    #GalleryMember.includes(:gallery, :user).all.each do |gallery_member|
    #  convert_membership_to_permissions(gallery_member.user, gallery_member.gallery, gallery_member.role)
    #end
  end

  def down
    # do nothing, all data should 
  end

  private

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
end
