require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AppConfig do
  it "is false if it does not exist" do
    AppConfig.is?('foo').should be_false
  end
  it "is default if it does not exist" do
    AppConfig.is?('foo', true).should be_true
  end

  it "is does not use default if key exists" do
    ENV['foo'] = 'true'
    AppConfig.is?('foo', false).should be_true
  end

  it "is value of key" do
    ENV['foo'] = 'true'
    AppConfig.is?('foo').should be_true
  end

  it "is value of key" do
    ENV['foo'] = 'false'
    AppConfig.is?('foo').should be_false
  end

  it "is value of key" do
    ENV['foo'] = 'true'
    AppConfig.is?('foo').should be_true
  end
  
  it "is value of key when it is a string" do
    ENV['foo'] = 'false'
    AppConfig.is?('foo').should be_false
  end
  
  it "is value of key when it is a string" do
    ENV['foo'] = 'true'
    AppConfig.is?('foo').should be_true
  end
  
end