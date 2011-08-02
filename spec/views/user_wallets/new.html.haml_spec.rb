require 'spec_helper'

describe "user_wallets/new.html.haml" do
  before(:each) do
    assign(:user_wallet, stub_model(UserWallet).as_new_record)
  end

  it "renders new user_wallet form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => user_wallets_path, :method => "post" do
    end
  end
end
