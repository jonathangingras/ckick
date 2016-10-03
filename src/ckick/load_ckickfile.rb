require "json"

module CKick
  def self.load_ckickfile(dir=Dir.pwd)
    JSON.parse(File.read(File.join(dir, "CKickFile")), symbolize_names: true)
  end
end
