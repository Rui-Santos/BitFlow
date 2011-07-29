require 'spec_helper'

describe "fund_deposits/new.html.haml" do
  before(:each) do
    assign(:fund_deposit, stub_model(FundDeposit).as_new_record)
  end

  it "renders new fund_deposit form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => fund_deposits_path, :method => "post" do
    end
  end
end
