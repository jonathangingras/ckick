require "spec_helper"

describe CKick::Path, '#initialize' do
  it "raises IllegalInitializationError when provided no Hash" do
    expect {CKick::Path.new()}.to raise_error(CKick::IllegalInitializationError)
  end

  it "raises IllegalInitializationError when provided an empty Hash" do
    expect {CKick::Path.new({})}.to raise_error(CKick::IllegalInitializationError)
  end

  it "raises IllegalInitializationError when provided a nil path" do
    expect {CKick::Path.new(path: nil)}.to raise_error(CKick::IllegalInitializationError)
  end

  it "is well instantiated with :path" do
    expect {CKick::Path.new(path: File.dirname(__FILE__))}.not_to raise_error
  end

  it "raises CKick::NoSuchDirectoryError when non-existing input dir" do
    filename = "somedir"
    allow(File).to receive(:exist?).with(filename).and_return(false)
    allow(Dir).to receive(:exist?).with(filename).and_return(false)

    expect {CKick::Path.new(path: filename)}.to raise_error CKick::NoSuchDirectoryError
  end

  it "raises CKick::NoSuchDirectoryError when input file is no dir" do
    filename = "somefile"
    allow(File).to receive(:exist?).with(filename).and_return(true)
    allow(Dir).to receive(:exist?).with(filename).and_return(false)

    expect {CKick::Path.new(path: filename)}.to raise_error CKick::NoSuchDirectoryError
    end
end

describe CKick::Path, '#to_s' do
  dirpath = File.dirname(__FILE__)
  path = CKick::Path.new(path: dirpath)

  it "gives path when converted to String" do
    expect(path.to_s).to eq(dirpath)
  end
end
