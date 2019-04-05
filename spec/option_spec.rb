require "spec_helper"

describe CKick::CLI::Option, '#initialize' do
  it "cannot instantiate an option without name" do
    expect {CKick::CLI::Option.new()}.to raise_error CKick::IllegalInitializationError
    expect {CKick::CLI::Option.new(name: "")}.to raise_error CKick::IllegalInitializationError
  end

  it "can initialize an option only from name" do
    expect {CKick::CLI::Option.new(name: "someoption")}.not_to raise_error
  end

  it "can initialize an option from name and description" do
    expect {CKick::CLI::Option.new(name: "someoption", description: "somedescription")}.not_to raise_error
  end

  it "cannot initialize an option from bad description" do
    expect {CKick::CLI::Option.new(name: "someoption", description: 1)}.to raise_error CKick::IllegalInitializationError
  end

  it "can instantiate an option with a empty hash of available arguments" do
    expect {CKick::CLI::Option.new(name: "someoption", available_arguments: {})}.not_to raise_error
  end

  it "can instantiate an option with a non-empty hash of available arguments" do
    expect {CKick::CLI::Option.new(name: "someoption",
                                   available_arguments: {
                                     somearg: "somevalue"
                                   })}.not_to raise_error
  end

  it "cannot instantiate an option with a non-legal hash of available arguments" do
    expect {CKick::CLI::Option.new(name: "someoption",
                                   available_arguments: {
                                     "somearg" => "somevalue"
                                   })}.to raise_error CKick::IllegalInitializationError
  end
end
