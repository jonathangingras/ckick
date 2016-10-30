# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

module CKick
  $PLUGIN_PATH = [File.join(File.absolute_path(File.dirname(__FILE__)), "plugin")]

  def self.find_builtin_plugins
    res = []
    $PLUGIN_PATH.each do |dir|
      files = Dir.entries(dir).select { |entry| entry.length > 3 && entry[-3..-1] == '.rb'}
      files.each do |file|
        res << File.join(dir, file)
      end
    end
    res.flatten(1)
  end

  def self.load_builtin_plugins
    find_builtin_plugins.each do |file|
      require file[0..-4]
    end
  end

end
