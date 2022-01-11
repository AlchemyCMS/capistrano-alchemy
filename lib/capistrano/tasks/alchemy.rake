namespace :alchemy do

  # Prepare Alchemy for deployment
  task :default_paths do
    set :linked_dirs, fetch(:linked_dirs, []) + %w(uploads public/pictures)
  end

  namespace :db do
    desc "Dumps the database into 'db/dumps' on the server."
    task dump: ['alchemy:default_paths', 'deploy:check'] do

      on roles :db do
        Database::Remote.new(self).dump
      end
    end
  end

  namespace :import do
    desc "Imports all data (Pictures, attachments and the database) into your local development machine."
    task all: ['db:local:sync', 'alchemy:default_paths', 'deploy:check'] do
      set :assets_dir, %w(public/pictures uploads/pictures uploads/attachments)
      set :local_assets_dir, %w(uploads)
      on roles [:app, :db] do
        invoke('assets:local:sync')
      end
    end

    desc "Imports the server database into your local development machine."
    task database: ['db:local:sync', 'alchemy:default_paths', 'deploy:check']

    desc "Imports attachments into your local machine using rsync."
    task attachments: ['alchemy:default_paths', 'deploy:check'] do
      set :assets_dir, %w(uploads/attachments)
      set :local_assets_dir, %w(uploads)
      on roles [:app, :db] do
        invoke('assets:local:sync')
      end
    end

    desc "Imports pictures into your local machine using rsync."
    task pictures: ['alchemy:default_paths', 'deploy:check'] do
      set :assets_dir, %w(public/pictures uploads/pictures)
      set :local_assets_dir, %w(uploads)
      on roles [:app, :db] do
        invoke('assets:local:sync')
      end
    end
  end

  namespace :export do
    desc "Sends all data (Pictures, attachments and the database) to your remote machine."
    task all: ['db:remote:sync', 'alchemy:default_paths', 'deploy:check'] do
      set :assets_dir, %w(public/pictures uploads/pictures uploads/attachments)
      set :local_assets_dir, %w(uploads)
      invoke('assets:remote:sync')
    end

    desc "Exports the local database into your server."
    task all: ['db:remote:sync', 'alchemy:default_paths', 'deploy:check']

    desc "Sends attachments to your remote machine using rsync."
    task attachments: ['alchemy:default_paths', 'deploy:check'] do
      set :assets_dir, %w(uploads/attachments)
      set :local_assets_dir, %w(uploads)
      invoke('assets:remote:sync')
    end

    desc "Sends pictures to your remote machine using rsync."
    task pictures: ['alchemy:default_paths', 'deploy:check'] do
      set :assets_dir, %w(public/pictures uploads/attachments)
      set :local_assets_dir, %w(uploads)
      invoke('assets:remote:sync')
    end
  end

  desc "Upgrades production database to current Alchemy CMS version"
  task upgrade: ['alchemy:default_paths', 'deploy:check'] do
    on roles [:app, :db] do
      within release_path do
        with rails_env: fetch(:rails_env, 'production') do
          execute :rake, 'alchemy:upgrade'
        end
      end
    end
  end
end
