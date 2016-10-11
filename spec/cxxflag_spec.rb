require "spec_helper"

describe CKick::CXXFlag, '#cmake' do
  it "outputs appropriate set(CMAKE_CXX_FLAGS ...) command" do
    flag = CKick::CXXFlag.new(flag: FLAG_CONTENT)

    expect(flag.cmake).to eq(%Q{set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} #{FLAG_CONTENT}")})
  end
end
