require "capistrano/alchemy/version"

require 'fileutils'
require 'alchemy/tasks/helpers'
require 'capistrano/alchemy/deploy_support'

include Alchemy::Tasks::Helpers
include Capistrano::Alchemy::DeploySupport

load File.expand_path('../tasks/alchemy.rake', __FILE__)
load File.expand_path('../tasks/alchemy_capistrano_hooks.rake', __FILE__)
