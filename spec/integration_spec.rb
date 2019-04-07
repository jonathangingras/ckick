require "spec_helper"
require "pathname"
require "fileutils"
require 'tmpdir'
require "rake"
require "ckick/plugin/clang_complete"
require "ckick/plugin/gtest"

describe CKick, "integration" do
  INITIAL_DIRECTORY = Dir.pwd
  PROJECT_DIRECTORY = File.join("#{Dir.tmpdir}", "ckick_sample_project")
  PROJECT_BUILD_DIRECTORY = File.join(PROJECT_DIRECTORY, "build")

  after(:all) do
    Dir.chdir(INITIAL_DIRECTORY)
    FileUtils.rm_r(PROJECT_DIRECTORY)
  end

  def create_structure
    ckickfile_path = File.join(PROJECT_DIRECTORY, "CKickfile")
    FileUtils.mkdir_p(PROJECT_DIRECTORY)
    FileUtils.cp(File.join(CKick::RESOURCE_DIR, "default_cxx_project.json"), ckickfile_path)
    project = CKick::Project.new(CKick::load_ckickfile(PROJECT_DIRECTORY))
    Dir.chdir(project.absolute_root)
    project.create_structure
  end

  def build_project
    create_structure

    FileUtils.cp(File.join(CKick::RESOURCE_DIR, "example_main.cc"), File.join(PROJECT_DIRECTORY, "src", "main.cc"))
    FileUtils.cp(File.join(CKick::RESOURCE_DIR, "example_gtest.cc"), File.join(PROJECT_DIRECTORY, "test", "main_test.cc"))

    Rake.sh "cd #{PROJECT_BUILD_DIRECTORY} && cmake .. && make -j"
  end

  def test_project
    build_project

    Rake.sh "cd #{PROJECT_BUILD_DIRECTORY} && ctest"
  end

  it "can produce the sample project structure" do
    create_structure

    [
      "CKickfile",
      "include",
      "src",
      "src/CMakeLists.txt",
      "build",
      "test",
      "test/CMakeLists.txt"
    ].each do |path|
      expect(Pathname.new(File.join(PROJECT_DIRECTORY, path))).to exist
    end
  end

  it "can produce a build-able project for CMake from the sample project structure without errors" do
    build_project
  end

  it "can produce a test-able project for CMake from the sample project structure without errors" do
    test_project
  end
end
