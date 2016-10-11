require "spec_helper"

describe CKick::Dependencies, '#initialize' do
  it "initializes well when provided nothing" do
    expect {CKick::Dependencies.new()}.not_to raise_error
  end

  it "initializes well when provided empty Hash" do
    expect {CKick::Dependencies.new({})}.not_to raise_error
  end

  it "raises when :cflags is not an Array" do
    expect {CKick::Dependencies.new(cflags: 1)}.to raise_error CKick::IllegalInitializationError
  end

  it "raises when :cxxflags is not an Array" do
    expect {CKick::Dependencies.new(cxxflags: 1)}.to raise_error CKick::IllegalInitializationError
  end

  it "raises when :include is not an Array" do
    expect {CKick::Dependencies.new(include: 1)}.to raise_error CKick::IllegalInitializationError
  end

  it "raises when :lib is not an Array" do
    expect {CKick::Dependencies.new(lib: 1)}.to raise_error CKick::IllegalInitializationError
  end

  object1 = Object.new
  object2 = Object.new

  it "passes each element of :cflags to CFlag::new" do
    expect(CKick::CFlag).to receive(:new).with(flag: object1)
    expect(CKick::CFlag).to receive(:new).with(flag: object2)

    CKick::Dependencies.new(cflags: [object1, object2])
  end

  it "passes each element of :cxxflags to CXXFlag::new" do
    expect(CKick::CXXFlag).to receive(:new).with(flag: object1)
    expect(CKick::CXXFlag).to receive(:new).with(flag: object2)

    CKick::Dependencies.new(cxxflags: [object1, object2])
  end

  it "passes each element of :include to IncludePath::new" do
    expect(CKick::IncludePath).to receive(:new).with(path: object1)
    expect(CKick::IncludePath).to receive(:new).with(path: object2)

    CKick::Dependencies.new(include: [object1, object2])
  end

  it "passes each element of :lib to LibraryPath::new" do
    expect(CKick::LibraryPath).to receive(:new).with(path: object1)
    expect(CKick::LibraryPath).to receive(:new).with(path: object2)

    CKick::Dependencies.new(lib: [object1, object2])
  end
end

object1 = Object.new
object2 = Object.new

class CMakeAbleMock
  def cmake
    "cmake"
  end

  def raw_flag
    "raw_flag"
  end
end

describe CKick::Dependencies, '#cmake' do
  cmake_able_object = CMakeAbleMock.new
  let(:cmake_able) { cmake_able_object }

  it "calls each attributes's cmake method" do
    expect(CKick::CFlag).to receive(:new).with(flag: object1).and_return(cmake_able)
    expect(CKick::CFlag).to receive(:new).with(flag: object2).and_return(cmake_able)
    expect(CKick::CXXFlag).to receive(:new).with(flag: object1).and_return(cmake_able)
    expect(CKick::CXXFlag).to receive(:new).with(flag: object2).and_return(cmake_able)
    expect(CKick::IncludePath).to receive(:new).with(path: object1).and_return(cmake_able)
    expect(CKick::IncludePath).to receive(:new).with(path: object2).and_return(cmake_able)
    expect(CKick::LibraryPath).to receive(:new).with(path: object1).and_return(cmake_able)
    expect(CKick::LibraryPath).to receive(:new).with(path: object2).and_return(cmake_able)

    expect(cmake_able).to receive(:cmake).exactly(8).times

    CKick::Dependencies.new(cflags: [object1, object2],
                            cxxflags: [object1, object2],
                            include: [object1, object2],
                            lib: [object1, object2]).cmake
  end

  it "outputs join of each attributes cmake method using endl" do
    expect(CKick::CFlag).to receive(:new).with(flag: object1).and_return(cmake_able)
    expect(CKick::CFlag).to receive(:new).with(flag: object2).and_return(cmake_able)
    expect(CKick::CXXFlag).to receive(:new).with(flag: object1).and_return(cmake_able)
    expect(CKick::CXXFlag).to receive(:new).with(flag: object2).and_return(cmake_able)
    expect(CKick::IncludePath).to receive(:new).with(path: object1).and_return(cmake_able)
    expect(CKick::IncludePath).to receive(:new).with(path: object2).and_return(cmake_able)
    expect(CKick::LibraryPath).to receive(:new).with(path: object1).and_return(cmake_able)
    expect(CKick::LibraryPath).to receive(:new).with(path: object2).and_return(cmake_able)

    deps = CKick::Dependencies.new(cflags: [object1, object2],
                                   cxxflags: [object1, object2],
                                   include: [object1, object2],
                                   lib: [object1, object2])

    expect(deps.cmake).to eq(8.times.collect{"cmake,"}.join().split(",").join("\n"))
  end
end

describe CKick::Dependencies, '#flags' do
  mocks = 8.times.collect { CMakeAbleMock.new }
  let(:cmake_ables) { mocks }
  uniq_mock = CMakeAbleMock.new
  let(:uniq_cmake_able) { uniq_mock }

  it "calls each attribute's raw_flag method" do
    expect(CKick::CFlag).to receive(:new).with(flag: object1).and_return(cmake_ables[0])
    expect(CKick::CFlag).to receive(:new).with(flag: object2).and_return(cmake_ables[1])
    expect(CKick::CXXFlag).to receive(:new).with(flag: object1).and_return(cmake_ables[2])
    expect(CKick::CXXFlag).to receive(:new).with(flag: object2).and_return(cmake_ables[3])
    expect(CKick::IncludePath).to receive(:new).with(path: object1).and_return(cmake_ables[4])
    expect(CKick::IncludePath).to receive(:new).with(path: object2).and_return(cmake_ables[5])
    expect(CKick::LibraryPath).to receive(:new).with(path: object1).and_return(cmake_ables[6])
    expect(CKick::LibraryPath).to receive(:new).with(path: object2).and_return(cmake_ables[7])

    cmake_ables.each{ |cmake_able| expect(cmake_able).to receive(:raw_flag).once }

    CKick::Dependencies.new(cflags: [object1, object2],
                            cxxflags: [object1, object2],
                            include: [object1, object2],
                            lib: [object1, object2]).flags
  end

  it "returns array of each attribute's raw_flag method" do
    expect(CKick::CFlag).to receive(:new).with(flag: object1).and_return(cmake_ables[0])
    expect(CKick::CFlag).to receive(:new).with(flag: object2).and_return(cmake_ables[1])
    expect(CKick::CXXFlag).to receive(:new).with(flag: object1).and_return(cmake_ables[2])
    expect(CKick::CXXFlag).to receive(:new).with(flag: object2).and_return(cmake_ables[3])
    expect(CKick::IncludePath).to receive(:new).with(path: object1).and_return(cmake_ables[4])
    expect(CKick::IncludePath).to receive(:new).with(path: object2).and_return(cmake_ables[5])
    expect(CKick::LibraryPath).to receive(:new).with(path: object1).and_return(cmake_ables[6])
    expect(CKick::LibraryPath).to receive(:new).with(path: object2).and_return(cmake_ables[7])

    deps = CKick::Dependencies.new(cflags: [object1, object2],
                                   cxxflags: [object1, object2],
                                   include: [object1, object2],
                                   lib: [object1, object2])

    expect(deps.flags).to eq(8.times.collect{"raw_flag"})
  end

  it "uniques attributes before calling raw flags" do
    expect(CKick::CFlag).to receive(:new).with(flag: object1).and_return(uniq_cmake_able)
    expect(CKick::CFlag).to receive(:new).with(flag: object2).and_return(uniq_cmake_able)
    expect(CKick::CXXFlag).to receive(:new).with(flag: object1).and_return(uniq_cmake_able)
    expect(CKick::CXXFlag).to receive(:new).with(flag: object2).and_return(uniq_cmake_able)
    expect(CKick::IncludePath).to receive(:new).with(path: object1).and_return(uniq_cmake_able)
    expect(CKick::IncludePath).to receive(:new).with(path: object2).and_return(uniq_cmake_able)
    expect(CKick::LibraryPath).to receive(:new).with(path: object1).and_return(uniq_cmake_able)
    expect(CKick::LibraryPath).to receive(:new).with(path: object2).and_return(uniq_cmake_able)

    expect(uniq_cmake_able).to receive(:raw_flag).once

    CKick::Dependencies.new(cflags: [object1, object2],
                            cxxflags: [object1, object2],
                            include: [object1, object2],
                            lib: [object1, object2]).flags
  end
end

describe CKick::Dependencies, '#add_include' do
  it "raises when input is not a CKick::IncludePath" do
    expect {CKick::Dependencies.new().add_include(1)}.to raise_error CKick::BadIncludePathError
  end

  it "does not raise when input is a CKick::IncludePath" do
    mock = instance_double("CKick::IncludePath")
    expect(mock).to receive(:is_a?).with(CKick::IncludePath).and_return true

    expect {CKick::Dependencies.new().add_include(mock)}.not_to raise_error
  end
end

describe CKick::Dependencies, '#add_lib' do
  it "raises when input is not a CKick::LibraryPath" do
    expect {CKick::Dependencies.new().add_lib(1)}.to raise_error CKick::BadLibraryPathError
  end

  it "does not raise when input is a CKick::LibraryPath" do
    mock = instance_double("CKick::LibraryPath")
    expect(mock).to receive(:is_a?).with(CKick::LibraryPath).and_return true

    expect {CKick::Dependencies.new().add_lib(mock)}.not_to raise_error
  end
end
