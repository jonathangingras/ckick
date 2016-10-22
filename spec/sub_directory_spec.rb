require "spec_helper"

describe CKick::SubDirectory, '#initialize' do

  it "raises IllegalInitializationError if no name provided" do
    expect {CKick::SubDirectory.new()}.to raise_error CKick::IllegalInitializationError
  end

  it "raises IllegalInitializationError if empty name provided" do
    expect {CKick::SubDirectory.new(name: "")}.to raise_error CKick::IllegalInitializationError
  end

  it "initializes well when only name is provided" do
    expect {CKick::SubDirectory.new(name: "somedir")}.not_to raise_error
  end

  it "raises IllegalInitializationError if :libraries argument is not an Array" do
    expect {CKick::SubDirectory.new(name: "somedir", libraries: 1)}.to raise_error CKick::IllegalInitializationError
  end

  it "raises IllegalInitializationError if :executables argument is not an Array" do
    expect {CKick::SubDirectory.new(name: "somedir", executables: 1)}.to raise_error CKick::IllegalInitializationError
  end

  object1 = Object.new
  object2 = Object.new

  it "creates a CKick::Library for each object passed via :libraries" do
    expect(CKick::Library).to receive(:new).with(object1).once
    expect(CKick::Library).to receive(:new).with(object2).once

    CKick::SubDirectory.new(name: "somedir", libraries: [object1, object2])
  end

  it "creates a CKick::Executable for each object passed via :executables" do
    expect(CKick::Executable).to receive(:new).with(object1).once
    expect(CKick::Executable).to receive(:new).with(object2).once

    CKick::SubDirectory.new(name: "somedir", executables: [object1, object2])
  end

  it "raises IllegalInitializationError when is passed targets, but :has_cmake is false" do
    expect{CKick::SubDirectory.new(name: "somedir", has_cmake: false, executables: [])}.to raise_error CKick::BadSubDirectoryError
  end

  it "calls itself resursively with :subdirs elements" do
    subdir2 = {name: "somedir2", subdirs: [object2]}
    subdir1 = {name: "somedir1", subdirs: [subdir2]}

    expect(CKick::SubDirectory).to receive(:new).with(subdir1).and_call_original
    expect(CKick::SubDirectory).to receive(:new).with(subdir2).and_call_original
    expect(CKick::SubDirectory).to receive(:new).with(object2)

    CKick::SubDirectory.new(subdir1)
  end

  it "raises IllegalInitializationError if :subdirs not an Array" do
    expect {CKick::SubDirectory.new(name: "somedir", subdirs: 1)}.to raise_error CKick::IllegalInitializationError
  end
end

describe CKick::SubDirectory, '#to_s' do
  it "converts to String with name content" do
    expect(CKick::SubDirectory.new(name: "somedir").to_s).to eq("somedir")
  end
end

describe CKick::SubDirectory, '#path' do

  it "returns join of parent directory and name" do
    dir = CKick::SubDirectory.new(name: "somedir")
    dir.__send__ :set_parent, "someparent"

    expect(dir.path).to eq(File.join("someparent", "somedir"))
  end

  it "raises NoParentDirError when parent not set" do
    expect {CKick::SubDirectory.new(name: "somedir").path}.to raise_error CKick::NoParentDirError
  end

end

describe CKick::SubDirectory, '#create_structure' do

  it "creates directory to .path" do
    filemock = double("file like object")
    allow(File).to receive(:new).and_return(filemock)
    allow(filemock).to receive_messages(:<< => nil, close: nil)

    dir = CKick::SubDirectory.new(name: "somedir")
    dir.__send__ :set_parent, "someparent"

    expect(FileUtils).to receive(:mkdir_p).with(dir.path)

    dir.create_structure
  end

  it "creates CMakeLists.txt in .path" do
    filemock = double("file like object")
    allow(filemock).to receive_messages(:<< => nil, close: nil)

    dir = CKick::SubDirectory.new(name: "somedir")
    dir.__send__ :set_parent, "someparent"

    expect(FileUtils).to receive(:mkdir_p).with(dir.path)
    expect(File).to receive(:new).with(File.join(dir.path, "CMakeLists.txt"), "w").and_return(filemock)

    dir.create_structure
  end

  it "does not create CMakeLists.txt when has_cmake: false" do
    dir = CKick::SubDirectory.new(name: "somedir", has_cmake: false)
    dir.__send__ :set_parent, "someparent"

    expect(File).not_to receive(:new)

    dir.create_structure
  end

  it "calls every target :create_structure" do
    allow(FileUtils).to receive(:mkdir_p)
    object1 = double(CKick::Executable.name)
    object2 = double(CKick::Library.name)
    allow(object1).to receive_messages(:set_parent => nil, :cmake => "")
    allow(object2).to receive_messages(:set_parent => nil, :cmake => "")
    expect(CKick::Executable).to receive(:new).with(object1).and_return(object1)
    expect(CKick::Library).to receive(:new).with(object2).and_return(object2)
    filemock = double("file like object")
    allow(File).to receive(:new).and_return(filemock)
    allow(filemock).to receive_messages(:<< => nil, close: nil)

    dir = CKick::SubDirectory.new(name: "somedir", executables: [object1], libraries: [object2])
    dir.__send__ :set_parent, "someparent"

    expect(object1).to receive(:create_structure)
    expect(object2).to receive(:create_structure)

    dir.create_structure
  end

  it "calls every subdirs :create_structure" do
    allow(FileUtils).to receive(:mkdir_p)
    object1 = double(CKick::SubDirectory.name)
    object2 = double(CKick::SubDirectory.name)
    allow(object1).to receive_messages(:set_parent => nil, :cmake => "", name: "")
    allow(object2).to receive_messages(:set_parent => nil, :cmake => "", name: "")
    expect(CKick::SubDirectory).to receive(:new).with(object1).and_return(object1)
    expect(CKick::SubDirectory).to receive(:new).with(object2).and_return(object2)
    filemock = double("file like object")
    allow(File).to receive(:new).and_return(filemock)
    allow(filemock).to receive_messages(:<< => nil, close: nil)

    args = {name: "somedir", subdirs: [object1, object2]}
    expect(CKick::SubDirectory).to receive(:new).with(args).and_call_original
    dir = CKick::SubDirectory.new(args)
    dir.__send__ :set_parent, "someparent"

    expect(object1).to receive(:create_structure)
    expect(object2).to receive(:create_structure)

    dir.create_structure
  end

end

describe CKick::SubDirectory, '#cmake' do
  it "outputs every target's cmake first" do
    object1 = double(CKick::Executable.name)
    object2 = double(CKick::Library.name)
    expect(CKick::Executable).to receive(:new).with(object1).and_return(object1)
    expect(CKick::Library).to receive(:new).with(object2).and_return(object2)
    allow(object1).to receive_messages(:cmake => "OBJ")
    allow(object2).to receive_messages(:cmake => "OBJ")

    args = {name: "somedir", executables: [object1], libraries: [object2]}
    dir = CKick::SubDirectory.new(args)

    expect(dir.cmake).to eq(["OBJ", "OBJ"].join("\n"))
  end

  it "outputs every subdir's cmake second" do
    object1 = double(CKick::Executable.name)
    object2 = double(CKick::Library.name)
    object3 = double(CKick::SubDirectory.name)
    object4 = double(CKick::SubDirectory.name)
    expect(CKick::Executable).to receive(:new).with(object1).and_return(object1)
    expect(CKick::Library).to receive(:new).with(object2).and_return(object2)
    expect(CKick::SubDirectory).to receive(:new).with(object3).and_return(object3)
    expect(CKick::SubDirectory).to receive(:new).with(object4).and_return(object4)
    allow(object1).to receive_messages(:cmake => "OBJ")
    allow(object2).to receive_messages(:cmake => "OBJ")
    allow(object3).to receive_messages(:name => "NAME")
    allow(object4).to receive_messages(:name => "NAME")

    args = {name: "somedir", executables: [object1], libraries: [object2], subdirs: [object3, object4]}
    expect(CKick::SubDirectory).to receive(:new).with(args).and_call_original
    dir = CKick::SubDirectory.new(args)

    expect(dir.cmake).to eq(["OBJ",
                             "OBJ",
                             "add_subdirectory(NAME)",
                             "add_subdirectory(NAME)"].join("\n"))
  end

end

describe CKick::SubDirectory, '#set_parent' do

  it "calls every target's and subdirs's set_parent" do
    object1 = double(CKick::Executable.name)
    object2 = double(CKick::Library.name)
    object3 = double(CKick::SubDirectory.name)
    object4 = double(CKick::SubDirectory.name)
    expect(CKick::Executable).to receive(:new).with(object1).and_return(object1)
    expect(CKick::Library).to receive(:new).with(object2).and_return(object2)
    expect(CKick::SubDirectory).to receive(:new).with(object3).and_return(object3)
    expect(CKick::SubDirectory).to receive(:new).with(object4).and_return(object4)

    expect(object1).to receive(:set_parent).with(File.join("someparent", "somedir"))
    expect(object2).to receive(:set_parent).with(File.join("someparent", "somedir"))
    expect(object3).to receive(:set_parent).with(File.join("someparent", "somedir"))
    expect(object4).to receive(:set_parent).with(File.join("someparent", "somedir"))

    args = {name: "somedir", executables: [object1], libraries: [object2], subdirs: [object3, object4]}
    expect(CKick::SubDirectory).to receive(:new).with(args).and_call_original
    dir = CKick::SubDirectory.new(args)

    dir.__send__ :set_parent, "someparent"
  end

end

describe CKick::SubDirectory, '#to_hash' do
  it "does not output a hash containing :parent_dir key" do
    expect(CKick::SubDirectory.new(name: "somedir").to_hash.keys).not_to include(:parent_dir)
  end

  it "does not output a hash containing :has_cmake key when has_cmake is true" do
    expect(CKick::SubDirectory.new(name: "somedir", has_cmake: true).to_hash.keys).not_to include(:has_cmake)
  end

  it "does output a hash containing :has_cmake when key has_cmake is false" do
    expect(CKick::SubDirectory.new(name: "somedir", has_cmake: false).to_hash.keys).to include(:has_cmake)
  end
end
