require 'open-uri'

module Sablon
  class Image
    include Singleton
    attr_reader :definitions

    Definition = Struct.new(:name, :data, :rid) do
      def inspect
        "#<Image #{name}:#{rid}"
      end
    end

    def self.create_by_url(url, random = nil)
      path = URI(url).path
      image_name = "#{random || Random.new_seed}-#{File.extname(path)}"
      remote_file = open(url)
      Sablon::Image::Definition.new(image_name, remote_file.is_a?(StringIO) ? remote_file.read : IO.binread(remote_file))
    end

    def self.create_by_path(path, random = nil)
      image_name = "#{random || Random.new_seed}-#{File.extname(path)}"
      Sablon::Image::Definition.new(image_name, IO.binread(path))
    end
  end
end
