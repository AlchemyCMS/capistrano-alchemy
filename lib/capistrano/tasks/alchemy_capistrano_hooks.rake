namespace :load do
  task :defaults do
    invoke 'alchemy:default_paths'
  end
end

namespace :alchemy do
  # hook the deploy path into alchemy
  before 'import:all', 'deploy:check'
  before 'import:database', 'deploy:check'
  before 'import:pictures', 'deploy:check'
  before 'import:attachments', 'deploy:check'
  before 'upgrade', 'deploy:check'
  before 'db:seed', 'deploy:check'
  before 'db:dump', 'deploy:check'
end
