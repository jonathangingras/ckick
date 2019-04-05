# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

require "ckick/version"
require "ckick/project"
require "ckick/find_plugin"
require "ckick/ckickfile"
require "ckick/cli"

# CKick module
# contains all CKick core code
module CKick
  # location of the resource directory.
  # +RESOURCE_DIR+ contains default project files and non-code utilities
  RESOURCE_DIR = File.join(File.dirname(File.dirname(__FILE__)), "resource")

  # :nodoc:
  class Error < ::Exception
  end

  # :nodoc:
  class BadFlagError < Error
  end

  # :nodoc:
  class NoSuchDirectoryError < Error
  end

  # :nodoc:
  class IllegalInitializationError < Error
  end

  # :nodoc:
  class NoNameError < Error
  end

  # :nodoc:
  class NoSourceError < Error
  end

  # :nodoc:
  class BadProjectNameError < Error
  end

  # :nodoc:
  class BadSourceError < Error
  end

  # :nodoc:
  class BadLibError < Error
  end

  # :nodoc:
  class BadIncludePathError < Error
  end

  # :nodoc:
  class BadLibraryPathError < Error
  end

  # :nodoc:
  class BadSubDirectoryError < Error
  end

  # :nodoc:
  class NoParentDirError < Error
  end

  # :nodoc:
  class BadFileContentError < Error
  end

  # :nodoc:
  class BadDirectoryNameError < Error
  end

  # :nodoc:
  class BadTargetDependencyNameError < Error
  end

  # :nodoc:
  class BadTestDefinitionError < Error
  end
end
