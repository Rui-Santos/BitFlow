require 'spec_helper'

describe "fund_deposits/show.html.haml" do
  before(:each) do
    @fund_deposit = assign(:fund_deposit, stub_model(FundDeposit))
  end

  it "renders attributes in <p>" do
    render
  end
end
