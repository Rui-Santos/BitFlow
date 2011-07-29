require 'spec_helper'

describe "bankaccounts/new.html.haml" do
  before(:each) do
    assign(:bankaccount, stub_model(Bankaccount).as_new_record)
  end

  it "renders new bankaccount form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => bankaccounts_path, :method => "post" do
    end
  end
end
