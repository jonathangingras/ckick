# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

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

    def self.touch_file(filepath)
      FileUtils.touch(filepath)
    end

  end

end
