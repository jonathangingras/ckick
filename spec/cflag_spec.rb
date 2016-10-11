require "spec_helper"

describe CKick::CFlag, '#cmake' do
  it "outputs appropriate set(CMAKE_C_FLAGS ...) command" do
    flag = CKick::CFlag.new(flag: FLAG_CONTENT)

    expect(flag.cmake).to eq(%Q{set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} #{FLAG_CONTENT}")})
  end
end
