require 'spec_helper'

describe "user_wallets/edit.html.haml" do
  before(:each) do
    @user_wallet = assign(:user_wallet, stub_model(UserWallet))
  end

  it "renders the edit user_wallet form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => user_wallets_path(@user_wallet), :method => "post" do
    end
  end
end
