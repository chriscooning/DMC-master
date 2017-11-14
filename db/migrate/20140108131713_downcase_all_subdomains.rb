class DowncaseAllSubdomains < ActiveRecord::Migration
  def change
    User.find_each do |user|
      domain = user.subdomain
      user.update_column :subdomain, domain.to_s.downcase
    end
  end
end
