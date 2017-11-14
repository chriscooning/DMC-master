require "heywatch"

class VideoHandler

  include Rails.application.routes.url_helpers

  def process(resource)
    HeyWatch.submit(configure_job(resource), configatron.heywatch.api_key)
  end

  def process_robot_ping(params)
    video = Asset.find_by_secret(params[:secret])
    params[:output_urls].each do |job, urls|
      case job
      when /mp4_\d+p/ then process_encode(video, job, urls)
      when /jpg_\d+x/ then process_thumbnails(video, job, urls)
      when 'hls' then process_hls(video, urls)
      end
    end
    video.processed = true
    video.save
  rescue
  end

  private

    def process_thumbnails(video, job, urls)
      video.video_thumbnail = [*urls].first if job == 'jpg_550x'
      encoded_params = {
        job => [*urls].first
      }
      video.video_thumbnails.merge!(encoded_params)
    end

    def process_encode(video, job, url)
      encoded_params = {
        job => url
      }
      video.video_urls.merge!(encoded_params)
    end

    def process_hls(video, url)
      video.m3u8_url = url
    end

    def prepare_rtmp(url)
      return url unless configatron.aws.cloudfront_host?
      url.gsub(/(http(s)?:\/\/)([^\/]+\/)/, "rtmp://#{configatron.aws.cloudfront_host}/cfx/st/mp4:")
    end

    def configure_job(video)
      #assign_all_attributes
      output_root = output_root(video.account)
      video_id = video.id
      video_title = "#{video.id}"
      video_url = URI::encode(video.file.url)
      thumb_width = 550
      robot_ping_url = callback_url secret: video.secret, protocol: protocol
      file = File.read(Rails.root.join('app', 'services', 'heywatch.conf.erb'))
      ERB.new(file).result(binding)
    end

    def protocol
      Rails.env.production? ? :https : :http
    end

    def callback_url(options = {})
      options.merge! host: configatron.host
      robot_callback_url options
    end

    def output_root(account)
      folder = account.s3_hash
      URI::encode("s3://#{configatron.aws.access_key}:#{configatron.aws.secret_key}@#{configatron.aws.bucket}/#{folder}")
    end

    def s3_encoded_url(video, params)
      output_root(video.user) + "/videos/#{video.id}/converted/#{params[:format_id]}/#{params[:filename]}" 
    end
end
