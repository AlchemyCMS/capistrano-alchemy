require "capistrano/alchemy/version"

require 'fileutils'
require 'capistrano-db-tasks'

load File.expand_path('../tasks/alchemy.rake', __FILE__)
load File.expand_path('../tasks/alchemy_capistrano_hooks.rake', __FILE__)
