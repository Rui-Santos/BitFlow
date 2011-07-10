require 'spec_helper'

describe "asks/index.html.haml" do
  before(:each) do
    assign(:asks, [
      stub_model(Ask),
      stub_model(Ask)
    ])
  end

  it "renders a list of asks" do
    render
  end
end
