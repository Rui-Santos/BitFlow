require 'spec_helper'

describe "user_wallets/show.html.haml" do
  before(:each) do
    @user_wallet = assign(:user_wallet, stub_model(UserWallet))
  end

  it "renders attributes in <p>" do
    render
  end
end
