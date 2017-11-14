if defined? AWS
  AWS.config(access_key_id: configatron.aws.access_key, secret_access_key: configatron.aws.secret_key, http_continue_threshold: 1024 * 1024)
end