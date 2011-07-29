require 'spec_helper'

describe "bankaccounts/edit.html.haml" do
  before(:each) do
    @bankaccount = assign(:bankaccount, stub_model(Bankaccount))
  end

  it "renders the edit bankaccount form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => bankaccounts_path(@bankaccount), :method => "post" do
    end
  end
end
