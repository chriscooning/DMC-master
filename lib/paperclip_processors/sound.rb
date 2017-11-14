# requirements:
#   ffmpeg with installed ogg support
#   ffmpeg wrapper - streamio-ffmpeg
#
# ffmpeg -i forcebewith.wav -ab 192k -ac 2 -ar 44100 ./forcebewith.mp3
# ffmpeg -i forcebewith.wav -ab 192k -ac 2 -ar 44100 -acodec libvorbis ./forcebewith.ogg
module Paperclip
  class Sound < Processor
    def initialize(file, options = {}, attachment = nil)
      super # stores file, options, attachment as attr_accessor

      @file                = file
      @current_format      = File.extname(@file.path)
      @basename            = File.basename(@file.path, @current_format)
      @format              = options[:format]
    end

    # options
    # {:processors=>[:sound], :format=>"ogg", :whiny=>true, :convert_options=>"", :source_file_options=>""}
    def make
      log("Making...")
      src = @file

      log("Building Destination File: '#{@basename}' + '#{@format}'")
      dst = Tempfile.new([@basename, @format ? ".#{@format}" : ''])
      dst.binmode
      log("Destination File Built") if @whiny

      begin
        source  = File.expand_path(src.path)
        dest    = File.expand_path(dst.path)

        movie = FFMPEG::Movie.new(src.path)
        movie.transcode(dst.path, transcode_options)

      rescue Exception => e
        raise Paperclip::Error, "There was an error processing the #{ @format } for #{@basename}" if @whiny
      end

      dst
    end

    private

    def transcode_options
      {}
    end

    def log(message)
      Paperclip.log "[sound processor] #{message}" if @whiny
    end
  end
end
