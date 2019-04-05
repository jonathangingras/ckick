find_package(Threads REQUIRED)
include(ExternalProject)

ExternalProject_Add(
  prufen-target
  GIT_REPOSITORY https://github.com/jonathangingras/prufen.git
  INSTALL_COMMAND ""
)

include_directories(${CMAKE_CURRENT_BINARY_DIR}/prufen-prefix/src/prufen/include)
