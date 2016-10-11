require "spec_helper"

FLAG_CONTENT = 'content'
FLAG = CKick::CompilerFlag.new(flag: FLAG_CONTENT)

describe CKick::CompilerFlag, '#initialize' do
  it "raises when nothing provided" do
    expect {CKick::CompilerFlag.new()}.to raise_error CKick::IllegalInitializationError
  end

  it "raises when empty Hash provided" do
    expect {CKick::CompilerFlag.new({})}.to raise_error CKick::IllegalInitializationError
  end

  it "raises when non-String flag provided" do
    expect {CKick::CompilerFlag.new(flag: 1)}.to raise_error CKick::BadFlagError
  end

  it "raises when empty String flag provided" do
    expect {CKick::CompilerFlag.new(flag: "")}.to raise_error CKick::BadFlagError
  end

  it "initializes well when String flag provided" do
    expect {CKick::CompilerFlag.new(flag: FLAG_CONTENT)}.not_to raise_error
  end
end

describe CKick::CompilerFlag, '#to_s' do
  it "converts flag to String as is" do
    expect(FLAG.to_s).to eq(FLAG_CONTENT)
  end
end

describe CKick::CompilerFlag, '#raw_flag' do
  it "outputs flag raw content" do
    expect(FLAG.raw_flag).to eq(FLAG_CONTENT)
  end
end

describe CKick::CompilerFlag, 'uniqueness' do
  it "is uniqued in an Array when content equal" do
    flag1 = CKick::CompilerFlag.new(flag: FLAG_CONTENT)
    flag2 = CKick::CompilerFlag.new(flag: FLAG_CONTENT)
    array = [flag1, flag2]

    array.uniq!

    expect(array.length).to eq(1)
    expect(array[0].raw_flag).to eq(FLAG_CONTENT)
  end
end
