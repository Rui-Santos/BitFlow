class TruncateData < ActiveRecord::Migration
  def self.up
    Ask.all.each {|x| x.destroy}
    Bankaccount.all.each {|x| x.destroy}
    Bid.all.each {|x| x.destroy}
    BtcWithdrawRequest.all.each {|x| x.destroy}
    FundDepositRequest.all.each {|x| x.destroy}
    FundTransactionDetail.all.each {|x| x.destroy}
    FundWithdrawRequest.all.each {|x| x.destroy}
    Trade.all.each {|x| x.destroy}
    Fund.all.each {|x| x.update_attributes :amount=>0.0,:reserved=>0.0,:available=>0.0}
  end

  def self.down
  end
end
