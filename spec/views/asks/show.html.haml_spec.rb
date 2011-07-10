require 'spec_helper'

describe "asks/show.html.haml" do
  before(:each) do
    @ask = assign(:ask, stub_model(Ask))
  end

  it "renders attributes in <p>" do
    render
  end
end
