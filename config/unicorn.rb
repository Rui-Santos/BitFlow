source_folder = "/apps/BitFlow/current"
worker_processes 1
working_directory source_folder

# This loads the application in the master process before forking
# worker processes
# Read more about it here:
# http://unicorn.bogomips.org/Unicorn/Configurator.html
preload_app true

timeout 30

# This is where we specify the socket.
# We will point the upstream Nginx module to this socket later on
listen "#{source_folder}/tmp/sockets/unicorn.sock", :backlog => 64

pid "#{source_folder}/tmp/pids/unicorn.pid"

# Set the path of the log files inside the log folder of the testapp
stderr_path "#{source_folder}/log/unicorn.stderr.log"
stdout_path "#{source_folder}/log/unicorn.stdout.log"
