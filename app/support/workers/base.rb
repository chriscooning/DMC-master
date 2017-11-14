class Workers::Base
  include Sidekiq::Worker

  def self.enqueue(*params)
    async? ? Sidekiq::Client.enqueue(self, *params) : self.new.perform(*params)
  end

  def self.async?
    Rails.env.production? || Rails.env.staging?
  end
end
