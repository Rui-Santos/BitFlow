require 'spec_helper'

describe "bankaccounts/index.html.haml" do
  before(:each) do
    assign(:bankaccounts, [
      stub_model(Bankaccount),
      stub_model(Bankaccount)
    ])
  end

  it "renders a list of bankaccounts" do
    render
  end
end
