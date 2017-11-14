require 'spec_helper'

def check_title_parse(file_name, expected_title, parse_options = {})
  expect(
    FilenameParser.new(file_name: file_name, options: parse_options).title
  ).to eq(expected_title)
end

describe FilenameParser do
  context "#parsing title" do
    it "convert BroccoliSlaw.jpg --> Broccoli Slaw" do
      check_title_parse('BroccoliSlaw.jpg', 'Broccoli Slaw')
    end

    it "convert broccoliSlaw.jpg --> Broccoli Slaw" do
      check_title_parse('broccoliSlaw.jpg', 'Broccoli Slaw')
    end

    it "convert broccoli_slaw.jpg --> Broccoli Slaw" do
      check_title_parse('broccoli_slaw.jpg', 'Broccoli Slaw')
    end

    it "convert broccoli-slaw.jpg --> Broccoli Slaw" do
      check_title_parse('Broccoli slaw.jpg', 'Broccoli Slaw')
    end

    it "convert IMAGE_0001.JPG - > Image" do
      check_title_parse('IMAGE_0001.JPG', 'Image')
    end
  end

  context "#parsing file extension" do
    it "should reject known extensions" do
      %w{JPG JPEG GIF PNG PDF XLS XLSX DOC DOCX AI ESP PSD PPT PPTX}.each do |ext|
        check_title_parse("Cats.#{ ext }", 'Cats')
      end
    end

    it "should store unknown/non-default extensions" do
      check_title_parse('Cats.exe', 'Cats EXE')
      check_title_parse('Cats.BAT', 'Cats BAT')
    end
  end

  context "#numbers on end of file" do
    it "should remove serial number in end of file name" do
      check_title_parse('Seals0001.jpg', 'Seals')
      check_title_parse('Seals 001.jpg', 'Seals')
    end

    it "should store names with digitals only" do
      check_title_parse('007.jpg', '007')
    end

    it "should ignore dates" do
      check_title_parse('birthday 2014-06-05.jpg', 'Birthday 2014-06-05')
    end
  end
end
