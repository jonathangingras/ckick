require "ckick/version"
require "ckick/project"
require "ckick/find_plugin"
require "ckick/ckickfile"

module CKick
  class Error < ::Exception
  end

  class BadFlagError < Error
  end

  class NoSuchDirectoryError < Error
  end

  class IllegalInitializationError < Error
  end

  class NoNameError < Error
  end

  class NoSourceError < Error
  end

  class BadSourceError < Error
  end

  class BadLibError < Error
  end

  class BadIncludePathError < Error
  end

  class BadLibraryPathError < Error
  end

  class NoParentDirError < Error
  end
end
