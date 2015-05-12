require "capistrano/alchemy/version"

require 'fileutils'
require 'alchemy/tasks/helpers'
# Loading the rails app
# require './config/environment.rb'
# so we can read the current mount point of Alchemy
require 'alchemy/mount_point'
require 'capistrano/alchemy/deploy_support'

include Alchemy::Tasks::Helpers
include Capistrano::Alchemy::DeploySupport

load File.expand_path('../tasks/alchemy.rake', __FILE__)
load File.expand_path('../tasks/alchemy_capistrano_hooks.rake', __FILE__)

