module Paperclip
  class Attachment
    class << self
      alias_method :origin_default_options, :default_options
      def default_options
        options = origin_default_options.deep_merge({
          default_url: '/defaults/:attachment/:style.png'
        })
        if configatron.aws.enabled?
          options.deep_merge!({
            storage:      :s3,
            url:          ":s3_domain_url",
            path:         ":account_s3_hash/:file_s3_folder/:id/:style/:filename",
            bucket:       configatron.aws.bucket,
            s3_credentials: {
              access_key_id: configatron.aws.access_key,
              secret_access_key: configatron.aws.secret_key,
            },
            s3_protocol: 'https',
            s3_host_alias: configatron.aws.cloudfront_host
          })
        end
        options
      end
    end
  end
end
Paperclip.interpolates(:account_s3_hash) do |attachment, style|
  if attachment.instance.is_a? Account
    attachment.instance.s3_hash
  else
    attachment.instance.account.s3_hash
  end
end
Paperclip.interpolates(:file_s3_folder) do |attachment, style|
  attachment.instance.s3_folder
end
Paperclip.interpolates(:account_owner_id) do |attachment, style|
  attachment.instance.owner_id
end
