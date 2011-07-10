require 'spec_helper'

describe "asks/edit.html.haml" do
  before(:each) do
    @ask = assign(:ask, stub_model(Ask))
  end

  it "renders the edit ask form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => asks_path(@ask), :method => "post" do
    end
  end
end
