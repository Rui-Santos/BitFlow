require 'spec_helper'

describe "bids/index.html.haml" do
  before(:each) do
    assign(:bids, [
      stub_model(Bid),
      stub_model(Bid)
    ])
  end

  it "renders a list of bids" do
    render
  end
end
