require "ostruct"
require "ckick/project"

module CKick
  class ConfigurationBuilder < OpenStruct
    def config(args={}, &block)
      configuration = ConfigurationBuilder.new
      args.each { |k, v| configuration[k] = v }
      configuration.instance_exec(configuration, &block) if block
      configuration.to_h
    end

    def plugin(name)
      raise "must be called in project root" unless self.in_project_root
      self.plugins = [] if self.plugins.nil?
      self.plugins << config(name: name)
    end

    def subdir(name, args={}, &block)
      raise "must be called in project root or a sub directory" unless (self.in_project_root || self.in_subdir)
      args[:in_subdir] = true
      args[:name] = name
      self.subdirs = [] if self.subdirs.nil?
      self.subdirs << config(args, &block)
      self.subdirs.last.reject! { |k| k == :in_subdir }
    end

    def executable(name, source, args={}, &block)
      raise "must be called in a sub directory" unless self.in_subdir
      args[:name] = name
      args[:source] = source
      self.executables = [] if self.executables.nil?
      self.executables << config(args, &block)
    end

    def library(name, source, args={}, &block)
      raise "must be called in a sub directory" unless self.in_subdir
      args[:name] = name
      args[:source] = source
      self.libraries = [] if self.libraries.nil?
      self.libraries << config(args, &block)
    end
  end

  def self.configure_project(&block)
    config = ConfigurationBuilder.new
    config.in_project_root = true
    config.instance_exec(config, &block)
    result = config.to_h
    result.reject! { |k| k == :in_project_root }
    Project.new(result)
  end
end
