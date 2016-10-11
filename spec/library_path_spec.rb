require "spec_helper"

describe CKick::LibraryPath, '#raw_flag' do
  dirpath = File.dirname(__FILE__)
  path = CKick::LibraryPath.new(path: dirpath)

  it "returns appropriate -L... compiler flag" do
    expect(path.raw_flag).to eq("-L#{dirpath}")
  end
end

describe CKick::LibraryPath, '#cmake' do
  dirpath = File.dirname(__FILE__)
  path = CKick::LibraryPath.new(path: dirpath)

  it "outputs appropriate CMake link_directories(...) command" do
    expect(path.cmake).to eq(%Q{link_directories(#{dirpath})})
  end
end
