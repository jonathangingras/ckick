require "spec_helper"

describe CKick::Target, '#initialize' do
  it "raises CKick::IllegalInitializationError when provided nothing" do
    expect {CKick::Target.new()}.to raise_error CKick::IllegalInitializationError
  end

  it "raises CKick::IllegalInitializationError when provided non-Hash" do
    expect {CKick::Target.new(1)}.to raise_error CKick::IllegalInitializationError
  end

  it "raises CKick::NoNameError when no name provided" do
    expect {CKick::Target.new(source: ["somefile"])}.to raise_error CKick::NoNameError
    expect {CKick::Target.new(name: nil, source: ["somefile"])}.to raise_error CKick::NoNameError
  end

  it "raises CKick::NoNameError when empty name provided" do
    expect {CKick::Target.new(name: "", source: ["somefile"])}.to raise_error CKick::NoNameError
  end

  it "raises CKick::NoNameError when non-String name provided" do
    expect {CKick::Target.new(name: 1, source: ["somefile"])}.to raise_error CKick::NoNameError
  end

  it "raises CKick::NoSourceError when provided no source" do
    expect {CKick::Target.new(name: "somename")}.to raise_error CKick::NoSourceError
  end

  it "raises CKick::NoSourceError when provided empty array as source" do
    expect {CKick::Target.new(name: "somename", source: [])}.to raise_error CKick::NoSourceError
  end

  it "initializes well with single String source file name" do
    expect {CKick::Target.new(name: "somename", source: "somesource")}.not_to raise_error
  end

  it "raises when neither String or Array provided as source" do
    expect {CKick::Target.new(name: "somename", source: 1)}.to raise_error CKick::BadSourceError
  end

  it "raises when Array of not-only-Strings provided as source" do
    expect {CKick::Target.new(name: "somename", source: [1, "hello"])}.to raise_error CKick::BadSourceError
  end

  it "initializes well when single String lib name provided as libs" do
    expect {CKick::Target.new(name: "somename", source: "somesource", libs: "somelib")}.not_to raise_error
  end

  it "initializes well when lib names array provided as libs" do
    expect {CKick::Target.new(name: "somename", source: "somesource", libs: ["somelib1", "somelib2"])}.not_to raise_error
  end

  it "raises when non-String or non-Array provided as libs" do
    expect {CKick::Target.new(name: "somename", source: "somesource", libs: 1)}.to raise_error CKick::BadLibError
  end

  it "raises when non-all-String Array provided as libs" do
    expect {CKick::Target.new(name: "somename", source: "somesource", libs: [1, "somelib"])}.to raise_error CKick::BadLibError
  end

  it "creates a LibraryLink when one lib provided" do
    expect(CKick::LibraryLink).to receive(:new).with({name: "somelib1"})

    CKick::Target.new(name: "somename", source: "somesource", libs: "somelib1")
  end

  it "creates a LibraryLink for each lib provided" do
    expect(CKick::LibraryLink).to receive(:new).with({name: "somelib1"})
    expect(CKick::LibraryLink).to receive(:new).with({name: "somelib2"})

    CKick::Target.new(name: "somename", source: "somesource", libs: ["somelib1", "somelib2"])
  end
end

describe CKick::Target, '#to_s' do
  it "outputs name when converted to String" do
    expect(CKick::Target.new(name: "somename", source: "somesource").to_s).to eq("somename")
  end
end

describe CKick::Target, '#paths' do
  it "raises when no parent set" do
    target = CKick::Target.new(name: "somename", source: "somesource")

    expect { target.paths }.to raise_error CKick::NoParentDirError
  end

  it "outputs single-value array when initialized with single source file name" do
    target = CKick::Target.new(name: "somename", source: "somesource")
    target.__send__ :set_parent, "someparent"

    expect(target.paths).to eq(["someparent/somesource"])
  end

  it "outputs multiple-value array when initialized with multiple source file names" do
    target = CKick::Target.new(name: "somename", source: ["somesource1", 'somesource2'])
    target.__send__ :set_parent, "someparent"

    expect(target.paths).to eq(["someparent/somesource1", "someparent/somesource2"])
  end
end

describe CKick::Target, '#create_structure' do
  it "raises when no parent set" do
    target = CKick::Target.new(name: "somename", source: "somesource")

    expect { target.create_structure }.to raise_error CKick::NoParentDirError
  end

  it "should create a single file when it does not already exist" do
    allow(File).to receive(:exist?).with("someparent/somesource1").and_return(false)

    target = CKick::Target.new(name: "somename", source: "somesource1")
    target.__send__ :set_parent, "someparent"

    expect(FileUtils).to receive(:touch).with("someparent/somesource1")

    target.create_structure
  end

  it "should create files when they do not already exist" do
    allow(File).to receive(:exist?).with("someparent/somesource1").and_return(false)
    allow(File).to receive(:exist?).with("someparent/somesource2").and_return(false)

    target = CKick::Target.new(name: "somename", source: ["somesource1", 'somesource2'])
    target.__send__ :set_parent, "someparent"

    expect(FileUtils).to receive(:touch).with("someparent/somesource1")
    expect(FileUtils).to receive(:touch).with("someparent/somesource2")

    target.create_structure
  end

  it "should only create files that do not already exist" do
    allow(File).to receive(:exist?).with("someparent/somesource1").and_return(true)
    allow(File).to receive(:exist?).with("someparent/somesource2").and_return(false)

    target = CKick::Target.new(name: "somename", source: ["somesource1", 'somesource2'])
    target.__send__ :set_parent, "someparent"

    expect(FileUtils).not_to receive(:touch).with("someparent/somesource1")
    expect(FileUtils).to receive(:touch).with("someparent/somesource2")

    target.create_structure
  end

  it "should create no file when they all exist" do
    allow(File).to receive(:exist?).with("someparent/somesource1").and_return(true)
    allow(File).to receive(:exist?).with("someparent/somesource2").and_return(true)

    target = CKick::Target.new(name: "somename", source: ["somesource1", 'somesource2'])
    target.__send__ :set_parent, "someparent"

    expect(FileUtils).not_to receive(:touch)

    target.create_structure
  end
end
