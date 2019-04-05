require "spec_helper"

describe CKick::CLI::Command, '#execute' do
  it "responds to :execute" do
    expect(CKick::CLI::Command.new.respond_to?(:execute)).to be true
  end
end
