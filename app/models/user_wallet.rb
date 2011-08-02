class UserWallet < ActiveRecord::Base
	belongs_to :user

	module  Status
    	ACTIVE = :active
    	CANCELLED = :cancelled
  	end
end
