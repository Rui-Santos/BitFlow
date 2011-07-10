require 'spec_helper'

describe "bids/edit.html.haml" do
  before(:each) do
    @bid = assign(:bid, stub_model(Bid))
  end

  it "renders the edit bid form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => bids_path(@bid), :method => "post" do
    end
  end
end
