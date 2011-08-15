set :user, "ubuntu"


role :web, "ec2-46-51-191-212.eu-west-1.compute.amazonaws.com" # Your HTTP server, Apache/etc
role :app, "ec2-46-51-191-212.eu-west-1.compute.amazonaws.com" #This may be the same as your `Web` server
role :db,  "ec2-46-51-191-212.eu-west-1.compute.amazonaws.com", :primary => true # This is where Rails migrations will run

