class Bankaccount < ActiveRecord::Base
  belongs_to :user
  
  validates_presence_of :name, :number
  
  def save
    begin
      super
    rescue => e
      self.errors.add_to_base('Account number for this bank already exists')
      return false
    end
  end
  
end
