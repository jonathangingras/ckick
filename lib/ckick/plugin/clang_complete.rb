# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

require "ckick/plugin"

class ClangComplete < CKick::Plugin
  # Creates a .clang_complete file for clang auto completion

  def call(project)
    def clang_complete project
      project.dependencies.flags.join("\n")
    end

    file = File.new(File.join(project.path, ".clang_complete"), 'w')
    file << clang_complete(project) << "\n"
    file.close
  end
end
