class DbResetAfterSplit < ActiveRecord::Migration
  def self.up
    Ask.all.each {|x| x.destroy}
    Bid.all.each {|x| x.destroy}
    Trade.all.each {|x| x.destroy}
    Fund.all.each {|f| f.update_attributes(:amount=>100,:reserved=>0,:available=>100)}
  end

  def self.down
  end
end
