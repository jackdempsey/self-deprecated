require File.dirname(__FILE__) + '/spec_helper'
require 'thor/runner'
load File.join(File.dirname(__FILE__), "..", "self-deprecated.thor")

describe Merb do
  it "runs deprecations" do
    silence(:stdout) { lambda { Merb.new.deprecations }.should_not raise_error }
  end
end
