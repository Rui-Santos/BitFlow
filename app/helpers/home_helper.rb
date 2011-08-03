module HomeHelper
	def unused_referral_code
		if current_user.nil?
			''
		else
			'Referral Code: ' + current_user.referral_code
		end
	end

	def unused_referral_code_link
		if current_user.nil?
			''
		else
			'Referral Code link: http://localhost:3000/users/sign_up?referrer_code='+current_user.referral_code
		end
	end

	def referral_code_unused?
		if current_user.nil?
			false
		else
			current_user.referral_code_unused?
		end
	end
end
