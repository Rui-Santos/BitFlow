module HomeHelper
	def referral_code
		if current_user.nil?
			''
		else
			'Referral Code: ' + current_user.referral_code
		end
	end

	def referral_code_link
		if current_user.nil?
			''
		else
			'Referral Code link: ' + request.url + 'users/sign_up?referrer_code=' + current_user.referral_code
		end
	end

end
