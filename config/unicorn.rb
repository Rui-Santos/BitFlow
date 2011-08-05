source_folder = "/apps/BitFlow/current"
shared_folder = "/apps/BitFlow/shared"

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
listen "#{shared_folder}/sockets/unicorn.sock", :backlog => 64

pid "#{shared_folder}/pids/unicorn.pid"

# Set the path of the log files inside the log folder of the testapp
stderr_path "#{source_folder}/log/unicorn.stderr.log"
stdout_path "#{source_folder}/log/unicorn.stdout.log"

before_fork do |server, worker|
  defined?(ActiveRecord::Base) && ActiveRecord::Base.connection.disconnect!

  old_pid = RAILS_ROOT + '/tmp/pids/unicorn.pid.oldbin'
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      puts "Old master alerady dead"
    end
  end
end

after_fork do |server, worker|
  defined?(ActiveRecord::Base) && ActiveRecord::Base.establish_connection
end
