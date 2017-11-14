class AccountUser < ActiveRecord::Base
  belongs_to :account
  counter_culture :account
  belongs_to :user
end
