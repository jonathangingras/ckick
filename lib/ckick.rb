# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

require "ckick/version"
require "ckick/project"
require "ckick/find_plugin"
require "ckick/ckickfile"

module CKick
  RESOURCE_DIR = File.join(File.dirname(File.dirname(__FILE__)), "resource")

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

  class BadProjectNameError < Error
  end

  class BadSourceError < Error
  end

  class BadLibError < Error
  end

  class BadIncludePathError < Error
  end

  class BadLibraryPathError < Error
  end

  class BadSubDirectoryError < Error
  end

  class NoParentDirError < Error
  end

  class BadFileContentError < Error
  end
end
