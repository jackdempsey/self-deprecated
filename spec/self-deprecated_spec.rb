require File.dirname(__FILE__) + '/spec_helper'
require 'rubygems'
require 'thor/runner'
require 'pp'
load File.join(File.dirname(__FILE__), "..", "self-deprecated.thor")

versioned_messages = {
  '0.9.0' => {'0.9.0 task' => 'bar'},
  '0.9.1' => {'0.9.1 task' => 'bar'},
  '0.9.2' => {'0.9.2 task' => 'bar'},
  '0.9.3' => {'0.9.3 task' => 'bar'},
  '0.9.4' => {'0.9.4 task' => 'bar'}
}

describe Merb do
  it "runs deprecations" do
    ARGV.replace ["merb:deprecations"]
    silence(:stdout) { proc { Thor::Runner.start }.should_not raise_error }
  end

  it "uses version if supplied" do
    ARGV.replace ["merb:deprecations", '-v','0.9.5']
    mock(Merb).messages('0.9.5') { {'empty' => 'hash'} }
    silence(:stdout) { Thor::Runner.start }
  end

  it "grabs tasks for the version equal to the one passed in" do
    mock(Merb).versioned_messages { versioned_messages }
    Merb.messages('0.9.1').should include('0.9.1 task')
  end

  it "grabs tasks for a version less than the one passed in" do
    mock(Merb).versioned_messages { versioned_messages }
    Merb.messages('0.9.1').should include('0.9.0 task')
  end

  it "does not grab task for a version greater than the one passed in" do
    mock(Merb).versioned_messages { versioned_messages }
    Merb.messages('0.9.1').should_not include('0.9.2 task')
  end

  it "does not use version if not supplied" do
    ARGV.replace ["merb:deprecations"]
    mock(Merb).messages(nil) { {'empty' => 'hash'} }
    silence(:stdout) { Thor::Runner.start }
  end

end
