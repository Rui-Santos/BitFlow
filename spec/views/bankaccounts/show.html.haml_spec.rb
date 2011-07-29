require 'spec_helper'

describe "bankaccounts/show.html.haml" do
  before(:each) do
    @bankaccount = assign(:bankaccount, stub_model(Bankaccount))
  end

  it "renders attributes in <p>" do
    render
  end
end
