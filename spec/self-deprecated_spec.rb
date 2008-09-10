require File.dirname(__FILE__) + '/spec_helper'
require 'rubygems'
require 'thor/runner'
load File.join(File.dirname(__FILE__), "..", "self-deprecated.thor")

describe Merb do
  it "runs deprecations" do
    ARGV.replace ["merb:deprecations"]
    silence(:stdout) { proc { Thor::Runner.start }.should_not raise_error }
  end

  it "uses version if supplied" do
    ARGV.replace ["merb:deprecations", '-v','0.9.5']
    mock.instance_of(Merb).messages('0.9.5') { {'empty' => 'hash'} }
    silence(:stdout) { Thor::Runner.start }
  end

  it "does not use version if not supplied" do
    ARGV.replace ["merb:deprecations"]
    mock.instance_of(Merb).messages(nil) { {'empty' => 'hash'} }
    silence(:stdout) { Thor::Runner.start }
  end
end
