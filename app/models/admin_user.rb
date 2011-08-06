class AdminUser
  def self.usd
    User.where(:admin => true).first.usd
  end
  def self.btc
    User.where(:admin => true).first.btc
  end
  def self.id
    User.where(:admin => true).first.id
  end
end