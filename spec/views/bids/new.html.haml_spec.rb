require 'spec_helper'

describe "bids/new.html.haml" do
  before(:each) do
    assign(:bid, stub_model(Bid).as_new_record)
  end

  it "renders new bid form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => bids_path, :method => "post" do
    end
  end
end
