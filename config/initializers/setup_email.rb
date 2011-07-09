ActionMailer::Base.smtp_settings = {  
  :address              => "smtp.gmail.com",  
  :port                 => 587,  
  :domain               => "bitflow.com",  
  :user_name            => "bitflow.test",  
  :password             => "bitfl0wTest",  
  :authentication       => "plain",  
  :enable_starttls_auto => true  
}