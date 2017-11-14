# this model used to store OLD passwords, # to prevent their reusing. 
# keep in mind, what the same password generate different encrypted_password 
class AdminUserPassword < ActiveRecord::Base
  belongs_to :admin_user
end
