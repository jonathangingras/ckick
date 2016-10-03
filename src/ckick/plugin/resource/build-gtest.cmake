find_package(Threads REQUIRED)
include(ExternalProject)

ExternalProject_Add(
        libgtest
        URL https://github.com/google/googletest/archive/release-1.8.0.zip
        PREFIX ${CMAKE_CURRENT_BINARY_DIR}/gtest
        INSTALL_COMMAND ""
)

include_directories("${CMAKE_CURRENT_BINARY_DIR}/gtest/src/libgtest/googletest/include")
include_directories("${CMAKE_CURRENT_BINARY_DIR}/gtest/src/libgtest/googlemock/include")

link_directories("${CMAKE_CURRENT_BINARY_DIR}/gtest/src/libgtest-build/googlemock/gtest")
link_directories("${CMAKE_CURRENT_BINARY_DIR}/gtest/src/libgtest-build/googlemock")

set(GTEST_LIBRARIES pthread gtest gtest_main)
