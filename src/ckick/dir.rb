
class Dir
  def self.mkdirp name
    begin
      mkdir name
    rescue
    end
  end
end
