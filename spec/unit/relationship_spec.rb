require 'spec_helper'

require 'active_fedora'
require 'active_fedora/relationship'
require "rexml/document"
require 'mocha'
require 'uri'

include Mocha::API

describe ActiveFedora::Relationship do
  
  %/
  module ModelSpec
    class AudioRecord
      include ActiveFedora::Model

      relationship "parents", :is_part_of, [nil, :oral_history]      
    end
    
    class OralHistory
      include ActiveFedora::Model
      
      relationship "parts", :is_part_of, [:audio_record], :inbound => true
  end
  /%
  before(:each) do
    ActiveSupport::Deprecation.expects(:warn).with("ActiveFedora::Releationship is deprecated and will be removed in the next release").twice
    
    @test_relationship = ActiveFedora::Relationship.new
    @test_literal = ActiveFedora::Relationship.new(:is_literal=>true)
  end
  
  it "should provide #new" do
    ActiveFedora::Relationship.should respond_to(:new)
  end
  
  describe "#new" do
    ActiveSupport::Deprecation.expects(:warn).with("ActiveFedora::Releationship is deprecated and will be removed in the next release").twice
    test_relationship = ActiveFedora::Relationship.new(:subject => "demo:5", :predicate => "isMemberOf", :object => "demo:10")
    
    test_relationship.subject.should == "info:fedora/demo:5"
    test_relationship.predicate.should == "isMemberOf"
    test_relationship.object.should == "info:fedora/demo:10"
    test_relationship.is_literal.should == false
    test_literal = ActiveFedora::Relationship.new(:is_literal=>true)
    test_literal.is_literal.should == true
  end
  
  describe "#subject=" do
    it "should turn strings into fedora URIs" do
      @test_relationship.subject = "demo:6"
      @test_relationship.subject.should == "info:fedora/demo:6"
      @test_relationship.subject = "info:fedora/demo:7"
      @test_relationship.subject.should == "info:fedora/demo:7"
    end
    it "should use the pid of the passed object if it responds to #pid" do
      mock_fedora_object = stub("mock_fedora_object", :pid => "demo:stub_pid")
      @test_relationship.subject = mock_fedora_object
      @test_relationship.subject.should == "info:fedora/#{mock_fedora_object.pid}"
    end
  end
  
  describe "#object=" do
    it "should turn strings into Fedora URIs" do
      @test_relationship.object = "demo:11"
      @test_relationship.object.should == "info:fedora/demo:11"
    end
    it "should use the pid of the passed object if it responds to #pid" do
      mock_fedora_object = stub("mock_fedora_object", :pid => "demo:stub_pid")
      @test_relationship.object = mock_fedora_object
      @test_relationship.object.should == "info:fedora/#{mock_fedora_object.pid}"
    end
    it "should let URI objects stringify themselves" do
      @test_relationship.object = URI.parse("http://projecthydra.org")
      @test_relationship.object.should == "http://projecthydra.org"
    end
    it "should not turn literal property objects into Fedora URIs" do
      @test_literal.object = "foo"
      @test_literal.object.should == "foo"
    end
  end
  
  describe "#predicate=" do
    it "should default to setting the argument itself as the new subject" do
      @test_relationship.predicate = "isComponentOf"
      @test_relationship.predicate.should == "isComponentOf"
    end
  end

  
end