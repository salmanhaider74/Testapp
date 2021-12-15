# Puma can serve each request in a thread from an internal thread pool.
# The `threads` method setting takes two numbers: a minimum and maximum.
# Any libraries that use thread pools should be configured to match
# the maximum value specified for Puma. Default is set to 5 threads for minimum
# and maximum; this matches the default thread size of Active Record.
#
PROD_ENVS = %w[staging production].freeze

rails_env = ENV.fetch('RAILS_ENV') { ENV.fetch('RACK_ENV') { 'development' } }

if PROD_ENVS.include?(rails_env)
  directory '/var/app/current'
  threads 8, 32
  workers `grep -c processor /proc/cpuinfo`
  bind 'unix:///var/run/puma/my_app.sock'
  stdout_redirect '/var/log/puma/puma.log', '/var/log/puma/puma.log', true
else
  threads 5, 5
  port 3000
  pidfile 'tmp/pids/server.pid'
  plugin :tmp_restart
end

environment rails_env
