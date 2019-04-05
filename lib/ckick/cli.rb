# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

require "ckick/cli/command"
require "ckick/cli/option"
require "ckick/cli/command_hash"
require "ckick/string"

module CKick
  module CLI
    # TODO doc + specs
    def self.puts(*args)
      Kernel.print '[CKick] ', *args
      Kernel.puts ''
    end

    # TODO doc + specs
    def self.wrapped(&block)
      begin
        yield
      rescue => error
        puts error
        exit(1)
      end
    end

    # TODO doc + specs
    def self.find_project_root(from_path=Dir.pwd)
      path = from_path

      while !Dir.entries(path).include?("CKickfile")
        raise "could not find parent directory containing a CKickfile" unless path != File.dirname(path)
        path = File.dirname(path)
      end

      path
    end

    # TODO doc + specs
    def self.with_found_subdirectory(path, &block)
      project = CKick::Project.new(CKick::load_ckickfile(find_project_root(path)))
      yield project.find_subdirectory(path)
      CKick.save_ckickfile(project)
      kick
    end

    # TODO doc + specs
    def self.with_found_target(name, path, &block)
      with_found_subdirectory(path) do |subdir|
        yield subdir.find_target(name)
      end
    end

    # TODO doc + specs
    def self.new_project(name, *args)
      raise "bad usage" if name.nil?
      raise "file or directory already exists" if Dir.exist?(name)
      raise "bad project name containing non-alphanumeric characters" unless name.match(/^[[A-z][0-9]]+$/)

      FileUtils.mkdir_p(File.join(name, "src"))
      FileUtils.mkdir_p(File.join(name, "test"))
      Dir.chdir(name)

      project = CKick::Project.new(CKick::load_ckickfile(CKick::RESOURCE_DIR, "default_cxx_project.json", Dir.pwd))
      project.set_name(name)
      FileUtils.cp(File.join(CKick::RESOURCE_DIR, "example_main.cc"), File.join("src", "main.cc"))
      FileUtils.cp(File.join(CKick::RESOURCE_DIR, "example_gtest.cc"), File.join("test", "main_test.cc"))

      CKick.save_ckickfile(project)
    end

    # TODO doc + specs
    def self.kick(*args)
      project = CKick::Project.new(CKick::load_ckickfile(find_project_root))
      Dir.chdir(project.absolute_root)
      project.create_structure
    end

    # TODO doc + specs
    def self.build(*args)
      kick

      project = CKick::Project.new(CKick.load_ckickfile(find_project_root))
      Dir.chdir(project.absolute_root)

      relative_build_path = Pathname.new(project.root).relative_path_from(Pathname.new(project.build_dir)).to_s
      FileUtils.mkdir_p(project.build_dir)

      Dir.chdir(project.build_dir)
      puts "changing directory to `#{project.build_dir}'"

      cmake_options = args.select { |arg| arg.length > 2 && arg[0..1] == "-D" }
      puts "calling cmake"
      Rake.sh "cmake #{cmake_options.join(' ')} #{relative_build_path}" do |ok, res|
        puts "calling make"
        Rake.sh "make -j" if ok
      end
    end

    # TODO doc + specs
    def self.test(*args)
      build

      Rake.sh "ctest"
    end

    # TODO doc + specs
    def self.add_target(target_class, name, *args)
      path = Dir.pwd

      project = CKick::Project.new(CKick::load_ckickfile(find_project_root(path)))

      src_path = args.each do |filepath|
        Pathname.new(File.join(path, filepath)).relative_path_from(Pathname.new(path)).to_s
      end.collect.to_a

      project.find_subdirectory!(path).add_target(target_class.new(name: name, source: src_path))

      CKick.save_ckickfile(project)
    end

    # TODO doc + specs
    def self.add_exe(name, *args)
      add_target(CKick::Executable, name, *args)
    end

    # TODO doc + specs
    def self.add_lib(name, *args)
      add_target(CKick::Library, name, *args)
    end

    # TODO doc + specs
    def self.add_to(target_name, *args)
      target_path = Dir.pwd
      with_found_target(target_name, target_path) do |target|
        target.add_to_source(*(args.each do |file|
                                 Pathname.new(File.absolute_path(file))
                                   .relative_path_from(Pathname.new(target_path)).to_s
                               end.collect))
      end
    end

    # TODO doc + specs
    def self.link(target_name, *args)
      with_found_target(target_name, Dir.pwd) do |target|
        args.each { |lib| target.add_link(CKick::LibraryLink.new(name: lib)) }
      end
    end

    # TODO doc + specs
    def self.add_dir(name, *args)
      project = CKick::Project.new(CKick.load_ckickfile(find_project_root))
      project.find_subdirectory!(File.join(Dir.pwd, name))
      CKick.save_ckickfile(project)
    end

    # TODO doc + specs
    def self.set(varname, *args)
      project = CKick::Project.new(CKick.load_ckickfile(find_project_root))
      project.add_variable(CKick::Variable.new(name: varname, value: args.join(' ')))
      CKick.save_ckickfile(project)
    end
  end
end
