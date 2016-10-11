require "spec_helper"

describe CKick::IncludePath, '#raw_flag' do
  dirpath = File.dirname(__FILE__)
  path = CKick::IncludePath.new(path: dirpath)

  it "returns appropriate -I... compiler flag" do
    expect(path.raw_flag).to eq("-I#{dirpath}")
  end
end

describe CKick::IncludePath, '#cmake' do
  dirpath = File.dirname(__FILE__)
  path = CKick::IncludePath.new(path: dirpath)

  it "outputs appropriate CMake include_directories(...) command" do
    expect(path.cmake).to eq(%Q{include_directories(#{dirpath})})
  end
end
