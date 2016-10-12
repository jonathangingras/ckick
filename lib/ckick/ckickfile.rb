require "json"

module CKick
  def self.load_ckickfile(dir=Dir.pwd, filename="CKickfile")
    JSON.parse(File.read(File.join(dir, filename)), symbolize_names: true)
  end
end
