require 'spec_helper'

describe "user_wallets/index.html.haml" do
  before(:each) do
    assign(:user_wallets, [
      stub_model(UserWallet),
      stub_model(UserWallet)
    ])
  end

  it "renders a list of user_wallets" do
    render
  end
end
