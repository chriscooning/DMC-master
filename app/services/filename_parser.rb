# service designed to suggest title/description based on
# file names, for example
#     cats_on_the_beach.jpg => 'Cats on the beach'
#     diplom_#4.docx        => 'Diplom'
#     diplom_#4.tgz         => 'Diplom TGZ'
#     'Q@#%#@%'             => ''
class FilenameParser
  RESTRICTED_CHARS = /[&$+,\/:;=?@<>\[\]\{\}\|\\\^~%# ]/
  ALLOWED_EXTENSIONS = %w{JPG JPEG GIF PNG PDF XLS XLSX DOC DOCX AI ESP PSD PPT PPTX}

  attr_reader :file_name, :options

  def initialize(file_name: nil, options: {})
    @file_name  = file_name.to_s
    @options    = options
  end

  def title
    if additional_info.present?
      "#{ base_title } #{additional_info.join(' ')}"
    else
      base_title
    end
  end

  private

    def base_title
      @base_title ||= begin
        # remove extension from name
        result = File.basename(file_name, File.extname(file_name))

        # replace camel case with empty spaces 
        result.gsub!(/[A-Z]+/){|cap_letter| " #{cap_letter.capitalize}"}

        # remove special chars
        result = result.gsub(/[^\w\d]/, ' ').gsub('_', ' ')

        # remove numbers if we have enough letters)
        if can_remove_digits?(result)
          result.gsub!(/\d/, ' ')
        end

        # normalize - remove first and duplicated spaces
        result = result.gsub(/^\s*/, '').gsub(/\s*$/, '').gsub(/\s{1,}/, ' ')

        result.gsub(/\w+/) { |word| word.capitalize }
      end
    end

    def extension
      @extension ||= File.extname(file_name).gsub(/\./, '').upcase
    end

    def extension_allowed?
      ALLOWED_EXTENSIONS.include?(extension)
    end

    def additional_info
      @additional_info ||= begin
        result = []
        result.push(dates)     if dates.present?
        result.push(extension) unless extension_allowed?
        result.flatten
      end
    end

    # if we have enough info without them
    def can_remove_digits?(name)
      letters_num = name.scan(/[a-zA-Z]/).size
      digits_num  = name.scan(/\d/).size

      letters_num > 3 or letters_num >= digits_num
    end

    def dates
      result = []
      file_name.scan(/\d{1,4}.+\d{1,4}.+\d{1,4}/).each do |raw_date|
        date = Date.parse(raw_date) rescue nil
        if date
          result.push(date.to_date)
        end
      end

      result
    end
end
