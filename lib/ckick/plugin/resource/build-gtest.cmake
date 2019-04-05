find_package(Threads REQUIRED)
include(ExternalProject)

ExternalProject_Add(
  gtest-target
  URL https://github.com/google/googletest/archive/release-1.8.0.zip
  INSTALL_COMMAND ""
)

include_directories("${CMAKE_CURRENT_BINARY_DIR}/gtest-target-prefix/src/gtest-target/googletest/include")
include_directories("${CMAKE_CURRENT_BINARY_DIR}/gtest-target-prefix/src/gtest-target/googlemock/include")

link_directories("${CMAKE_CURRENT_BINARY_DIR}/gtest-target-prefix/src/gtest-target-build/googlemock/gtest")
link_directories("${CMAKE_CURRENT_BINARY_DIR}/gtest-target-prefix/src/gtest-target-build/googlemock")

set(GTEST_TARGET gtest-target)
set(GTEST_LIBRARIES gtest gtest_main gmock gmock_main pthread)
