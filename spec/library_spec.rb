require "spec_helper"

describe CKick::Library, '#cmake' do
  it "outputs appropriate CMake add_library(...) when single source" do
    cmake_code = CKick::Library.new(name: "somename", source: "somesource").cmake

    expect(cmake_code).to match(/add_library\(somename somesource\)/)
  end

  it "outputs appropriate CMake add_library(...) when multiple source" do
    cmake_code = CKick::Library.new(name: "somename", source: ["somesource1", "somesource2"]).cmake

    expect(cmake_code).to match(/add_library\(somename somesource1 somesource2\)/)
  end

  it "outputs appropriate CMake add_library(...) when single source and single lib" do
    cmake_code = CKick::Library.new(name: "somename", source: "somesource", libs: "somelib").cmake

    expect(cmake_code).to match(/add_library\(somename somesource\)/)
    expect(cmake_code).to match(/target_link_libraries\(somename somelib\)/)
  end

  it "outputs appropriate CMake add_library(...) when multiple source and multiple lib" do
    cmake_code = CKick::Library.new(name: "somename", source: ["somesource1", "somesource2"], libs: ["somelib1", "somelib2"]).cmake

    expect(cmake_code).to match(/add_library\(somename somesource1 somesource2\)/)
    expect(cmake_code).to match(/target_link_libraries\(somename somelib1 somelib2\)/)
  end

  it "does not output anything when no :install_dir" do
    cmake_code = CKick::Library.new(name: "somename", source: ["somesource1", "somesource2"]).cmake

    expect(cmake_code).not_to match(/install\(.*\)/)
  end

  it "does output install command when :install_dir present" do
    cmake_code = CKick::Library.new(name: "somename", source: ["somesource1", "somesource2"], install_dir: "lib").cmake

    expect(cmake_code).to match(/install\(.*\)/)
    end
end

describe CKick::Library, '#to_hash' do
  it "does not output a hash containing :shared when shared false" do
    expect(CKick::Library.new(name: "somename", source: ["somesource1", "somesource2"]).to_hash.keys).not_to include(:shared)
  end

  it "does output a hash containing :shared when shared true" do
    expect(CKick::Library.new(name: "somename", source: ["somesource1", "somesource2"], shared: true).to_hash.keys).to include(:shared)
  end
end
