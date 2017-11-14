require 'benchmark'
include ActionDispatch::TestProcess

def log(message, &block)
  puts "*** #{message}"
  time = Benchmark.realtime do
    block.call
  end.round(2)

  puts "- Total: #{time}s"
  puts
end

ASSET_IMAGES = Dir.glob(Rails.root.join('spec/fixtures/images/*.jpg')).sort
LOREM_IPSUM = 'Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.'

def sample_asset_image
  fixture_file_upload(ASSET_IMAGES.sample, 'image/jpg')
end