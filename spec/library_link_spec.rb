require "spec_helper"

describe CKick::LibraryLink, '#initialize' do
  it "raises when empty Hash provided" do
    expect {CKick::LibraryLink.new({})}.to raise_error CKick::IllegalInitializationError
  end

  it "raises when nothing provided" do
    expect {CKick::LibraryLink.new()}.to raise_error CKick::IllegalInitializationError
  end

  it "raises when non-String name provided" do
    expect {CKick::LibraryLink.new(name: 1)}.to raise_error CKick::IllegalInitializationError
  end

  it "raises when provided empty name" do
    expect {CKick::LibraryLink.new(name: "")}.to raise_error CKick::IllegalInitializationError
  end

  it "initializes well when provided name" do
    expect {CKick::LibraryLink.new(name: "somelib")}.not_to raise_error
  end
end

describe CKick::LibraryLink, '#to_s' do
  it "outputs name when converted to String" do
    expect(CKick::LibraryLink.new(name: "somelib").to_s).to eq("somelib")
  end
end

describe CKick::LibraryLink, '#raw_flag' do
  it "outputs appropriate compiler flag -l..." do
    expect(CKick::LibraryLink.new(name: "somelib").raw_flag).to eq("-lsomelib")
  end
end

describe CKick::LibraryLink, '#cmake' do
  it "outputs name as is" do
    expect(CKick::LibraryLink.new(name: "somelib").cmake).to eq("somelib")
  end
end

describe CKick::LibraryLink, '#to_hash_element' do
  it "outputs @name as is" do
    expect(CKick::LibraryLink.new(name: "somelib").to_hash_element).to eq("somelib")
  end
end
