class Asset < ActiveRecord::Base
  KNOWN_FILE_TYPES = %w[doc docx xls xlsx ppt pptx ai eps psd pdf zip txt]
  IMAGES_FORMATS = %w{jpeg jpg png gif bmp tiff tif}
  AUDIO_FORMATS = %w{mpeg wav mp3 ogg flac wmv wma opus aiff m4a aac}

  belongs_to :folder
  belongs_to :account
  has_many   :events, as: :target, dependent: :destroy

  acts_as_paranoid

  scope :processed, -> { where(processed: true) }

  serialize :video_urls, Hash
  serialize :video_thumbnails, Hash

  delegate :gallery_id, to: :folder, allow_nil: true

  paginates_per configatron.pagination.assets.per

  acts_as_taggable

  before_validation :assign_title

  validates :title, presence: true, length: { maximum: 50 }

  has_attached_file :file,
    styles: lambda { |attachment| attachment.instance.styles },
    processors: lambda { |instance| instance.processors },
    s3_url_options: {
      response_content_disposition: "attachment;"
    }

  has_attached_file :custom_thumbnail,
    styles: { medium: "530", large: "1140" },
    path: ":account_s3_hash/:file_s3_folder/:id/alt_thumb/:style/:filename"

  validates_attachment :custom_thumbnail, content_type: { content_type: /image\/(#{ IMAGES_FORMATS.join('|')})/}

  before_file_post_process :post_processing_required?

  before_create :generate_quicklink_hash, :generate_embedding_hash

  # enable paperclip processing for image & audio only
  def post_processing_required?
    image? || audio?
  end

  def name
    self.title
  end

  def styles
    if is_image
      if is_tiff
        { small: ['250x140#', :jpg], medium: ['530', :jpg], large: ['1140', :jpg] }
      else
        { small: '250x140#', medium: '530', large: '1140' }
      end
    elsif is_audio
      { ogg: { format: 'ogg' }, mp3: { format: 'mp3' } }
    else
      {} # don't touch video files or other documents
    end
  end

  def processors
    if is_image
      [:thumbnail]
    elsif is_audio
      [:sound]
    else
      []
    end
  end

  def file_url(style = :original)
    file.expiring_url(configatron.aws.url_expiring_time, style)
  end

  def audio_urls(styles = [:original, :mp3, :ogg])
    return [] unless audio?
    (styles || []).map do |style|
      file.expiring_url(configatron.aws.url_expiring_time, style)
    end
  end

  def s3_folder
    return 'videos' if video?
    #return 'videos' if audio? # video configured to have streaming. dev stuff
    return 'audios' if audio?
    return 'images' if image?
    'documents'
  end

  def thumb_url(style = :medium)
    if custom_thumbnail?
      custom_thumbnail_url(style)
    else
      if image?
        file_url(:small)
      elsif video?
        video_thumbnail
      else
        nil
      end
    end
  end

  def custom_thumbnail_url(style = :medium)
    custom_thumbnail.present? ? custom_thumbnail.url(style) : nil
  end

  def medium_url
    file_url(:medium) if image?
  end

  def large_url
    file_url(:large) if image?
  end

  def image?
    !!(file_content_type =~ /image\/(#{ IMAGES_FORMATS.join('|') })/)
  end

  def video?
    !!(file_content_type =~ /^video\//)
  end

  def audio?
    !!(file_content_type =~ /audio\/.*(#{ AUDIO_FORMATS.join('|') }.*)/)
  end

  def document?
    !(image? || video? || audio?)
  end

  def asset_type
    case
    when image?
      :image
    when audio?
      :audio
    when video?
      :video
    when document?
      :document
    else
      :document
    end
  end

  def document_type
    case
    when is_pdf
      :pdf
    else
      nil
    end
  end

  def is_image
    image?
  end

  def is_audio
    audio?
  end

  def is_video
    video?
  end

  def is_pdf
    !!(file_content_type =~ /application\/pdf/)
  end

  def is_tiff
    !!(file_content_type =~ /image\/tif/)
  end

  def s3_key
    file.path if file
  end

  def pdf_preview_url
    return unless is_pdf
    if file.path
      options = { expires: 3600, secure: true, response_content_type: 'application/pdf' }
      file.s3_object(:original).url_for(:read, options).to_s
    else
      file.url
    end
  end

  def icon_type
    if self.file_file_name
      ext_wit_dot = File.extname(self.file_file_name)
      ext = ext_wit_dot.split('.').last
      KNOWN_FILE_TYPES.include?(ext) && ext
    end
  end

  private

    def generate_quicklink_hash
      self.quicklink_hash ||= SecureRandom.hex
    end

    def generate_embedding_hash
      self.embedding_hash ||= SecureRandom.hex
    end

    def assign_title
      if title.blank?
        full_filename = self.file_file_name
        basename = File.basename(full_filename, File.extname(full_filename))
        self.title = basename
      end
    end
end
