require 'net/http'
require 'open-uri'
class UsersMigration
  BASE_HOST = 'digitalmediacenter.com'
  BASE_PORT = 80
  SKIP_USERS = %w(xyz987@yopmail.com xyz789@yopmail.com salosinm@gmail.com)
  MAX_RETRIES = 3
  MAX_VIDEO_PORTION = 5

  def process_all_images
    Asset.find_each do |asset|
      next unless asset.image?
      Workers::ImageProcessing.enqueue(asset.id)
    end
  end

  def process_videos
    queue_count = 1
    Asset.where(processed: false).find_each do |asset|
      break if queue_count > MAX_VIDEO_PORTION
      next unless asset.video?
      Workers::VideoProcessor.enqueue(asset.id)
      queue_count += 1
    end
  end

  def migrate
    ActiveRecord::Base.silence do
      get('httpapi/users').each do |attrs|
        next if SKIP_USERS.include?(attrs[:email])
        create_user(attrs)
      end
    end
  end

  def migrate_one_user(email)
    ActiveRecord::Base.silence do
      get('httpapi/users').each do |attrs|
        next unless attrs[:email] == email
        create_user(attrs)
      end
    end
  end

  def create_user(attrs)
    log "Migrating user: #{attrs[:email]}" do
      user = User.new(
        email: attrs[:email], 
        full_name: attrs[:name],
        subdomain: attrs[:subdomain],
        password: 'temporary_password'
      )
      user.skip_confirmation!
      return unless save_record(user, attrs)
      user.update_column(:encrypted_password, attrs[:encrypted_password])
      user.update_column(:confirmed_at, Date.parse(attrs[:confirmed_at])) if attrs[:confirmed_at]
      user.update_column(:created_at, Date.parse(attrs[:created_at])) if attrs[:created_at]
      gallery = user.galleries.new(name: attrs[:project][:name] || 'default')
      return unless save_record(gallery, attrs)
      get("httpapi/menulinks/#{attrs[:id]}").each do |menu_attrs|
        create_menu_link(gallery, menu_attrs)
      end
      get("httpapi/folders/#{attrs[:id]}").each do |folder_attrs|
        create_folder(gallery, folder_attrs)
      end
    end
  end

  def create_folder(gallery, attrs)
    folder = gallery.folders.new(
      name: attrs[:name],
      hide_folder: attrs[:ishidden],
      position: attrs[:priority]
    )
    save_record(folder, attrs, "* Creating folder #{attrs[:id]}..")
    print "*** Uploading assets.."
    unsaved_assets = []
    get("httpapi/assets/#{attrs[:id]}").each do |asset_attrs|
      success = create_asset(folder, asset_attrs)
      unless success
        unsaved_assets << {title: attrs[:mtitle], url: attrs[:originalUrl]}
      end
    end
    puts " Completed."
    if unsaved_assets.any?
      puts "*** The following assets were no saved:"
      puts unsaved_assets.inspect
    end
  end

  def create_asset(folder, attrs)
    title = attrs[:mtitle].present? ? attrs[:mtitle] : "Default"
    asset = folder.assets.new(title: title)
    asset.description = attrs[:mdescription]
    asset.user = folder.gallery.user
    asset.position = attrs[:priority]
    retries = 1
    begin
      retriable_file_processing(asset, attrs, retries)
    rescue Exception => e
      print 'F'
      p e.message
      p attrs[:originalUrl] if attrs[:originalUrl]
      return false
    end
  end

  def create_menu_link(gallery, attrs)
    begin
      menu_link = gallery.menu_link.new link: attrs[:url], content: attrs[:name]
      print (menu_link.save ? '.' : 'F')
    rescue
      print 'F'
    end
  end

  def save_record(record, attrs, message = nil)
    name = record.class.name.titleize.downcase
    message ||= "* Creating #{name}.."
    print message
    if record.save
      puts " Success."
    else
      puts " Error."
      puts "*** Can't create #{name} with following attrs: #{attrs}"
      puts "*** Reason: #{record.errors.messages}"
    end
    record.valid?
  end

  def get(path)
   response = Net::HTTP.start(BASE_HOST, BASE_PORT) do |http|
      req = Net::HTTP::Get.new("/#{path}")
      req.basic_auth 'dmc', 'dmcsite'
      http.request(req).body
    end
    JSON.parse(response).map(&:symbolize_keys)
  end

  def log(message, &block)
    puts message
    time = Benchmark.realtime do
      block.call
    end.round(2)

    puts "- Total: #{time}s"
    puts
  end

  private

    def retriable_file_processing(asset, attrs, retries)
      if retries > MAX_RETRIES
        print 'F'
        return false 
      else
        print 'R' if retries > 1
        retries += 1
        handle_file_processing(asset, attrs)
      end
    rescue AWS::S3::Errors::RequestTimeout
      retriable_file_processing(asset, attrs, retries)
    end

    def handle_file_processing(asset, attrs)
      if attrs[:originalUrl]
        asset.file = URI.parse(attrs[:originalUrl])
        asset.processed = false if asset.file_content_type =~ /(image|video)/
      end
      if asset.save
        print '.'
        return true
      else
        print 'F'
        p attrs[:originalUrl] if attrs[:originalUrl]
        p asset.errors.messages
        return false
      end
    end
end