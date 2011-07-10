# Run me with:
#   $ watchr specs.watchr

# --------------------------------------------------
# Rules
# --------------------------------------------------
watch( 'spec\/unit\/.*_spec.rb')  { |m| ruby  m[0] }
watch( 'spec\/integration\/.*_spec.rb')  { |m| ruby  m[0] }
watch( 'spec\/controllers\/.*_spec.rb')  { |m| ruby  m[0] }
watch( 'spec\/models\/.*_spec.rb')  { |m| ruby  m[0] }
watch( '^lib\/.*\/(.*)\.rb')  {|m| run_src(m[1])}   

watch( '^app\/.*\/(.*)\.rb'){|m| run_src(m[1])}
watch( 'spec_helper.rb')  { run_all_tests }

# --------------------------------------------------
# Signal Handling
# --------------------------------------------------
Signal.trap('QUIT') { run_all_tests  } # Ctrl-\
Signal.trap('INT' ) { abort("\n") } # Ctrl-C

# --------------------------------------------------
# Helpers
# --------------------------------------------------
def ruby(*paths)
  run "bundle exec rspec #{paths.join(' ')}"
end

def run_src(file)
  puts "Modified #{file}"
  files = Dir["spec/**/#{file}*_spec.rb"]
  ruby files 
end
def run(cmd)
  begin    
    puts cmd
    system cmd
  rescue LoadError => e
    puts "file in command not found. Rescuing"
  end
end

def run_all_tests
  system("bundle exec rake spec")
end

