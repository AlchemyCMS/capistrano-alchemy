namespace :alchemy do

  # TODO: split up this namespace into something that runs once on `cap install` and
  # once on every deploy
  desc "Prepare Alchemy for deployment."
  task :default_paths do
    set :alchemy_picture_cache_path,
      -> { File.join('public', Alchemy::MountPoint.get, 'pictures') }

    set :linked_dirs, fetch(:linked_dirs, []) + [
      "uploads/pictures",
      "uploads/attachments",
      fetch(:alchemy_picture_cache_path),
      "tmp/cache/assets"
    ]

    # TODO: Check, if this is the right approach to ensure that we don't overwrite existing settings?
    # Or does Capistrano already handle this for us?
    set :linked_files, fetch(:linked_files, []) + %w(config/database.yml)
  end

  # TODO: Do we really need this in Alchemy or should we release an official Capistrano plugin for that?
  namespace :database_yml do
    desc "Creates the database.yml file"
    task create: ['alchemy:default_paths', 'deploy:check'] do
      set :db_environment, ask("the environment", fetch(:rails_env, 'production'))
      set :db_adapter, ask("database adapter (mysql or postgresql)", 'mysql')
      set :db_adapter, fetch(:db_adapter).gsub(/\Amysql\z/, 'mysql2')
      set :db_name, ask("database name", nil)
      set :db_username, ask("database username", nil)
      set :db_password, ask("database password", nil)
      default_db_host = fetch(:db_adapter) == 'mysql2' ? 'localhost' : '127.0.0.1'
      set :db_host, ask("database host", default_db_host)
      db_config = ERB.new <<-EOF
#{fetch(:db_environment)}:
  adapter: #{fetch(:db_adapter)}
  encoding: utf8
  reconnect: false
  pool: 5
  database: #{fetch(:db_name)}
  username: #{fetch(:db_username)}
  password: #{fetch(:db_password)}
  host: #{fetch(:db_host)}
EOF
      on roles :app do
        execute :mkdir, '-p', "#{shared_path}/config"
        upload! StringIO.new(db_config.result), "#{shared_path}/config/database.yml"
      end
    end
  end

  namespace :db do
    desc "Seeds the database with essential data."
    task seed: ['alchemy:default_paths', 'deploy:check'] do
      on roles :db do
        within release_path do
          with rails_env: fetch(:rails_env, 'production') do
            execute :rake, 'alchemy:db:seed'
          end
        end
      end
    end

    desc "Dumps the database into 'db/dumps' on the server."
    task dump: ['alchemy:default_paths', 'deploy:check'] do
      on roles :db do
        within release_path do
          timestamp = Time.now.strftime('%Y-%m-%d-%H-%M')
          execute :mkdir, '-p', 'db/dumps'
          with dump_filename: "db/dumps/#{timestamp}.sql", rails_env: fetch(:rails_env, 'production') do
            execute :rake, 'alchemy:db:dump'
          end
        end
      end
    end
  end

  namespace :import do
    desc "Imports all data (Pictures, attachments and the database) into your local development machine."
    task all: ['alchemy:default_paths', 'deploy:check'] do
      on roles [:app, :db] do
        invoke('alchemy:import:pictures')
        puts "\n"
        invoke('alchemy:import:attachments')
        puts "\n"
        invoke('alchemy:import:database')
      end
    end

    desc "Imports the server database into your local development machine."
    task database: ['alchemy:default_paths', 'deploy:check'] do
      on roles :db do |server|
        puts "Importing database. Please wait..."
        system db_import_cmd(server)
        puts "Done."
      end
    end

    desc "Imports attachments into your local machine using rsync."
    task attachments: ['alchemy:default_paths', 'deploy:check'] do
      on roles :app do |server|
        get_files(:attachments, server)
      end
    end

    desc "Imports pictures into your local machine using rsync."
    task pictures: ['alchemy:default_paths', 'deploy:check'] do
      on roles :app do |server|
        get_files(:pictures, server)
      end
    end
  end

  namespace :export do
    desc "Sends all data (Pictures, attachments and the database) to your remote machine."
    task all: ['alchemy:default_paths', 'deploy:check'] do
      invoke 'alchemy:export:pictures'
      invoke 'alchemy:export:attachments'
      invoke 'alchemy:export:database'
    end

    desc "Imports the server database into your local development machine."
    task database: ['alchemy:default_paths', 'deploy:check'] do
      on roles :db do |host|
        within release_path do
          if ask(:backup_confirm, 'WARNING: This task will overwrite your remote database. Do you want me to make a backup? (y/n)') == "y"
            backup_database
            export_database(host)
          else
            if ask(:overwrite_confirm, 'Are you sure? (y/n)') == "y"
              export_database(host)
            else
              backup_database
              export_database(host)
            end
          end
        end
      end
    end

    desc "Sends attachments to your remote machine using rsync."
    task attachments: ['alchemy:default_paths', 'deploy:check'] do
      on roles :app do |host|
        send_files :attachments, host
      end
    end

    desc "Sends pictures to your remote machine using rsync."
    task pictures: ['alchemy:default_paths', 'deploy:check'] do
      on roles :app do |host|
        send_files :pictures, host
      end
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


