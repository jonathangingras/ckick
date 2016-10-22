module CKick

  class Plugin
    def initialize args
    end

    # Plugin's name, defaults to class name
    def name
      self.class.name
    end

    # Plugin to hash is :name => "class name"
    def to_hash
      {name: self.class.name}
    end

    # Plugin's output to add to main CMakeLists.txt
    def cmake
      ""
    end

    # Ran before project's structure creation
    def run(project)
      nil
    end

    # Ran after project's structure creation (create_structure)
    def call(project)
      nil
    end

    # Appends project's includes path before structure creation
    def include(project)
      []
    end

    # Appends project's libraries path before structure creation
    def lib(project)
      []
    end
  end

end
