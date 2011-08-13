require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe BitcoinProxy do
  it "creates a new accout" do
    BitcoinProxy.new_address('niket').should_not be_nil
  end

  it "creates a new account" do
    BitcoinProxy.all_addresses('niket').should_not be_nil
  end

  it "get balance" do
    BitcoinProxy.balance('niket', 5).should_not be_nil
  end
  
end
