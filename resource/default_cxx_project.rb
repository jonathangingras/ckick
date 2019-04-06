CKick.configure_project do |project|
  project.root = "."
  project.build_dir = "build"

  project.compiler_settings = {
    cxxflags: ["-std=c++11", "-O3"]
  }

  ["ClangComplete", "GTest"].each { |name| plugin(name) }

  subdir('include', has_cmake: false)

  subdir('src') do
    executable('main', 'main.cc')
  end

  subdir('test') do
    gtest_executable('main_test', 'main_test.cc')
  end
end
