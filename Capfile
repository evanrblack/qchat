# Load DSL and set up stages
require 'capistrano/setup'

# Include default deployment tasks
require 'capistrano/deploy'

# Set up SCM
require 'capistrano/scm/git'
install_plugin Capistrano::SCM::Git

# More tasks
require 'capistrano/rvm'
require 'capistrano/bundler'
require 'capistrano/thin'
require 'capistrano-resque'
