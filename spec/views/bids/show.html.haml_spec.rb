require 'spec_helper'

describe "bids/show.html.haml" do
  before(:each) do
    @bid = assign(:bid, stub_model(Bid))
  end

  it "renders attributes in <p>" do
    render
  end
end
