# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

require "json"

module CKick
  # loads a CKickfile in +dir+
  # * +dir+ - directory containing file, defaults to Dir.pwd
  # * +filename+ - filename, defaults to "CKickfile"
  def self.load_ckickfile(dir=Dir.pwd, filename="CKickfile", absolute_root=dir)
    if File.absolute_path(absolute_root) == CKick::RESOURCE_DIR
      raise "absolute_root parameter should differ from CKick::RESOURCE_DIR"
    end
    JSON.parse(File.read(File.join(dir, filename)), symbolize_names: true)
      .merge!({absolute_root: File.absolute_path(absolute_root)})
  end

  # saves a CKick::Project object as a CKickfile
  # * +project_path+ - CKick project root path
  # * +project+ - CKick::Project object
  def self.save_ckickfile(project, project_path=project.absolute_root)
    raise "not a CKick::Project" unless project.is_a?(Project)

    h = project.to_hash
    #h[:root] = Pathname.new(File.absolute_path(project.path)).relative_path_from(Pathname.pwd).to_s
    lines = JSON.pretty_generate(h, {indent: "  "}).split("\n")
    lines.collect! do |line|
      if line[2] == '"'
        line = "\n" + line
      end
      line
    end
    lines[1][0] = ""
    file_content = lines.join("\n")

    File.open(File.join(project_path, "CKickfile"), "w") { |file| file << file_content}
  end
end
