require 'spec_helper'

describe "fund_deposits/index.html.haml" do
  before(:each) do
    assign(:fund_deposits, [
      stub_model(FundDeposit),
      stub_model(FundDeposit)
    ])
  end

  it "renders a list of fund_deposits" do
    render
  end
end
