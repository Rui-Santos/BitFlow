class Bankaccount < ActiveRecord::Base
  belongs_to :user
  has_many :fund_deposits

  validates_presence_of :name, :number

  before_create :unique_bank_details

  def unique_bank_details
    bank_account = self
    in_db = Bankaccount.where(:name => bank_account.name, :number => bank_account.number, :status => bank_account.status).first
    if in_db
      bank_account.errors.add(:base, 'Bank Name and Account Number already exists')
      return false
    else
      return true
    end
  end

  def name_account
    "#{name}/#{number}"
  end

  module  Status
    ACTIVE = :active
    DELETED = :deleted
  end

end
