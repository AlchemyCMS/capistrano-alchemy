namespace :load do
  task :defaults do
    invoke 'alchemy:default_paths'
  end
end

namespace :deploy do
  after :migrate, 'db:seed'
end

