def create_user(attrs = {})
  account = Account.new
  account.subdomain = attrs[:subdomain]
  account.save

  attrs[:password_confirmation] = attrs[:password]
  user = account.users.new(attrs)
  user.skip_confirmation!
  user.save

  account.owner = user
  account.save
end

log "create Example user user@example.com : password" do
  create_user(
    full_name: "Example User",
    email: "user@example.com",
    password: "password",
    subdomain: 'example'
  )
end

log "create Bruce Lee user bruce@lee.com : password" do
  create_user(
    full_name: "Bruce Lee",
    email: "bruce@lee.com",
    password: "password",
    subdomain: 'bruce'
  )
end

log "create admin user admin@example.com : password" do
  AdminUser.create!(
    email: "admin@example.com",
    password: "!Passw0rd",
    password_confirmation: "!Passw0rd"
  )
end
