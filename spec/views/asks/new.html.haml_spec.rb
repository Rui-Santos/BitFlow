require 'spec_helper'

describe "asks/new.html.haml" do
  before(:each) do
    assign(:ask, stub_model(Ask).as_new_record)
  end

  it "renders new ask form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => asks_path, :method => "post" do
    end
  end
end
