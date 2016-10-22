require "spec_helper"

describe CKick::Library, '#cmake' do
  it "outputs appropriate CMake add_library(...) when single source" do
    expect(CKick::Library.new(name: "somename", source: "somesource").cmake).to eq(%Q{add_library(somename somesource)})
  end

  it "outputs appropriate CMake add_library(...) when multiple source" do
    expect(CKick::Library.new(name: "somename", source: ["somesource1", "somesource2"]).cmake).to eq(%Q{add_library(somename somesource1 somesource2)})
  end

  it "outputs appropriate CMake add_library(...) when single source and single lib" do
    expect(CKick::Library.new(name: "somename", source: "somesource", libs: "somelib").cmake).to eq(%Q{add_library(somename somesource)\ntarget_link_libraries(somename somelib)})
  end

  it "outputs appropriate CMake add_library(...) when multiple source and multiple lib" do
    expect(CKick::Library.new(name: "somename", source: ["somesource1", "somesource2"], libs: ["somelib1", "somelib2"]).cmake).to eq(%Q{add_library(somename somesource1 somesource2)\ntarget_link_libraries(somename somelib1 somelib2)})
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
