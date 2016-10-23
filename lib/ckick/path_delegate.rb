require "fileutils"

module CKick

  module PathDelegate

    def self.create_directory(dirpath)
      FileUtils.mkdir_p(dirpath)
    end

    def self.write_file(dirpath, filename, content)
      raise BadFileContentError, "content does not respond to to_s" unless content.respond_to?(:to_s)
      filepath = File.join(dirpath, filename)
      file = File.new(filepath, "w")
      file << content.to_s
      file.close
    end

  end

end
