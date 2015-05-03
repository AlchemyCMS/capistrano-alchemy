require "capistrano/alchemy/version"
# These are Capistrano tasks for handling the uploads and picture cache files while deploying your application.
#
require 'fileutils'
require 'alchemy/tasks/helpers'
# Loading the rails app
# require './config/environment.rb'
# so we can read the current mount point of Alchemy
require 'alchemy/mount_point'

include Alchemy::Tasks::Helpers

load File.expand_path('../tasks/alchemy.rake', __FILE__)
load File.expand_path('../tasks/alchemy_capistrano_hooks.rake', __FILE__)

