require File.dirname(__FILE__) + '/spec_helper'
require 'rubygems'
require 'thor/runner'
load File.join(File.dirname(__FILE__), "..", "self-deprecated.thor")

describe Merb do
  it "runs deprecations" do
    ARGV.replace ["merb:deprecations"]
    silence(:stdout) { proc { Thor::Runner.start }.should_not raise_error }
  end
end
