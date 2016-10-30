require "spec_helper"

describe CKick::Project, '#initialize' do
  it "raises if name empty" do
    expect {CKick::Project.new(name: "", root: Dir.pwd, build_dir: "build")}.to raise_error CKick::IllegalInitializationError
  end

  it "raises if name non-String" do
    expect {CKick::Project.new(name: 1, root: Dir.pwd, build_dir: "build")}.to raise_error CKick::IllegalInitializationError
  end

  it "raises if name non-alphanumeric" do
    expect {CKick::Project.new(name: "!hello", root: Dir.pwd, build_dir: "build")}.to raise_error CKick::IllegalInitializationError
  end

  it "raises if cmake_min_version non-String" do
    expect {CKick::Project.new(name: "someproject", root: Dir.pwd, build_dir: "build", cmake_min_version: 1)}.to raise_error CKick::IllegalInitializationError
  end

  it "raises if cmake_min_version has non working pattern x or x.y or x.y.z" do
    expect {CKick::Project.new(name: "someproject", root: Dir.pwd, build_dir: "build", cmake_min_version: "10")}.to raise_error CKick::IllegalInitializationError
  end

  it "does not raise if cmake_min_version has working pattern x or x.y or x.y.z" do
    expect {CKick::Project.new(name: "someproject", root: Dir.pwd, build_dir: "build", cmake_min_version: "1")}.not_to raise_error
  end

  it "does not raise if cmake_min_version has working pattern x or x.y or x.y.z" do
    expect {CKick::Project.new(name: "someproject", root: Dir.pwd, build_dir: "build", cmake_min_version: "1.1")}.not_to raise_error
  end

  it "does not raise if cmake_min_version has working pattern x or x.y or x.y.z" do
    expect {CKick::Project.new(name: "someproject", root: Dir.pwd, build_dir: "build", cmake_min_version: "1.1.1")}.not_to raise_error
  end

  it "raises if no root directory" do
    expect {CKick::Project.new(name: "someproject", build_dir: "build")}.to raise_error CKick::IllegalInitializationError
  end

  it "raises if empty root directory" do
    expect {CKick::Project.new(name: "someproject", root: "", build_dir: "build")}.to raise_error CKick::IllegalInitializationError
  end

  it "raises if non-String root directory" do
    expect {CKick::Project.new(name: "someproject", root: 1, build_dir: "build")}.to raise_error CKick::IllegalInitializationError
  end

  it "raises if no build directory" do
    expect {CKick::Project.new(name: "someproject", root: Dir.pwd)}.to raise_error CKick::IllegalInitializationError
  end

  it "raises if empty build directory" do
    expect {CKick::Project.new(name: "someproject", root: Dir.pwd, build_dir: "")}.to raise_error CKick::IllegalInitializationError
  end

  it "raises if non-String build directory" do
    expect {CKick::Project.new(name: "someproject", root: Dir.pwd, build_dir: 1)}.to raise_error CKick::IllegalInitializationError
  end

  it "passes dependencies hash to Dependencies.new" do
    object = Object.new
    expect(CKick::Dependencies).to receive(:new).with(object)

    CKick::Project.new(name: "someproject", root: Dir.pwd, build_dir: "build", dependencies: object)
  end

  it "passes each subdir hash to SubDirectory.new" do
    object1 = Object.new
    object2 = Object.new
    allow(object1).to receive(:set_parent).with(anything())
    allow(object2).to receive(:set_parent).with(anything())

    expect(CKick::SubDirectory).to receive(:new).with(object1).and_return(object1)
    expect(CKick::SubDirectory).to receive(:new).with(object2).and_return(object2)

    CKick::Project.new(name: "someproject", root: Dir.pwd, build_dir: "build", subdirs: [object1, object2])
  end

  it "calls each subdir's set_parent" do
    object1 = Object.new
    object2 = Object.new
    allow(CKick::SubDirectory).to receive(:new).with(object1).and_return(object1)
    allow(CKick::SubDirectory).to receive(:new).with(object2).and_return(object2)

    expect(object1).to receive(:set_parent).with(File.absolute_path(Dir.pwd))
    expect(object2).to receive(:set_parent).with(File.absolute_path(Dir.pwd))

    CKick::Project.new(name: "someproject", root: Dir.pwd, build_dir: "build", subdirs: [object1, object2])
  end

  it "finds each plugin by PluginDelegate" do
    plugin = double("CKick::Plugin")

    expect(CKick::PluginDelegate).to receive(:find).with(plugin).and_return(plugin)

    CKick::Project.new(name: "someproject", root: Dir.pwd, build_dir: "build", plugins: [plugin])
  end

end

describe CKick::Project, '#path' do
  it "returns root path as is" do
    expect(CKick::Project.new(name: "someproject", root: ".", build_dir: "build").path).to eq(".")
  end
end

describe CKick::Project, '#set_name' do
  it "raises when name non-alphanumeric" do
    expect {CKick::Project.new(name: "someproject", root: ".", build_dir: "build").set_name("project!")}.to raise_error CKick::BadProjectNameError
  end

  it "raises when name non-String" do
    expect {CKick::Project.new(name: "someproject", root: ".", build_dir: "build").set_name(1)}.to raise_error CKick::BadProjectNameError
  end

  it "does not raise when name alphanumeric" do
    expect {CKick::Project.new(name: "someproject", root: ".", build_dir: "build").set_name("project")}.not_to raise_error
  end
end

describe CKick::Project, '#create_structure' do
  it "creates root directory with PathDelegate" do
    allow(CKick::PathDelegate).to receive(:write_file).with(anything(), anything(), anything())
    project = CKick::Project.new(name: "someproject", root: ".", build_dir: "build")

    expect(CKick::PathDelegate).to receive(:create_directory).with(".")

    project.create_structure
  end

  it "creates CMakeLists.txt in root directory with PathDelegate" do
    allow(CKick::PathDelegate).to receive(:write_file).with(anything(), anything(), anything())
    allow(CKick::PathDelegate).to receive(:create_directory).with(".")
    project = CKick::Project.new(name: "someproject", root: ".", build_dir: "build")

    expect(CKick::PathDelegate).to receive(:write_file).with(".", "CMakeLists.txt", project.cmake)

    project.create_structure
  end

  it "calls each subdir #create_structure" do
    allow(CKick::PathDelegate).to receive(:write_file).with(anything(), anything(), anything())
    sub1, sub2 = double("CKick::SubDirectory"), double("CKick::SubDirectory")
    allow(sub1).to receive_messages(set_parent: nil, has_cmake: true, name: "")
    allow(sub2).to receive_messages(set_parent: nil, has_cmake: true, name: "")
    allow(CKick::SubDirectory).to receive(:new).with(sub1).and_return(sub1)
    allow(CKick::SubDirectory).to receive(:new).with(sub2).and_return(sub2)
    project = CKick::Project.new(name: "someproject", root: ".", build_dir: "build", subdirs: [sub1, sub2])

    expect(sub1).to receive(:create_structure)
    expect(sub2).to receive(:create_structure)

    project.create_structure
  end

  it "runs and calls each plugin" do
    allow(CKick::PathDelegate).to receive(:write_file).with(anything(), anything(), anything())
    plugin1 = double("CKick::Plugin")
    plugin2 = double("CKick::Plugin")
    allow(CKick::PluginDelegate).to receive(:find).with(plugin1).and_return plugin1
    allow(CKick::PluginDelegate).to receive(:find).with(plugin2).and_return plugin2
    project = CKick::Project.new(name: "someproject", root: ".", build_dir: "build", plugins: [plugin1, plugin2])

    expect(plugin1).to receive(:run).with(project)
    expect(plugin2).to receive(:run).with(project)
    expect(plugin1).to receive(:include).with(project)
    expect(plugin2).to receive(:include).with(project)
    expect(plugin1).to receive(:lib).with(project)
    expect(plugin2).to receive(:lib).with(project)
    expect(plugin1).to receive(:call).with(project)
    expect(plugin2).to receive(:call).with(project)

    project.create_structure
  end
end
