require 'spinner'

module Capistrano::Alchemy::DeploySupport
  # Makes a backup of the remote database and stores it in db/ folder
  def backup_database
    puts 'Backing up database'
    timestamp = Time.now.strftime('%Y-%m-%d-%H-%M')
    rake "RAILS_ENV=#{fetch(:rails_env, 'production')} alchemy:db:dump DUMP_FILENAME=db/dump-#{timestamp}.sql"
  end

  # Sends the database via ssh to the server
  def export_database(server)
    puts "Exporting the database. Please wait..."
    system db_export_cmd(server)
  end

  def db_import_cmd(server)
    raise "No server given" if !server
    dump_cmd = "cd #{release_path} && bundle exec rake RAILS_ENV=#{fetch(:rails_env, 'production')} alchemy:db:dump"
    sql_stream = "#{ssh_command(server)} '#{dump_cmd}'"
    "#{sql_stream} | #{database_import_command(database_config['adapter'])} 1>/dev/null 2>&1"
  end

  # The actual export command that sends the data
  def db_export_cmd(server)
    raise "No server given" if !server
    import_cmd = "cd #{release_path} && bundle exec rake RAILS_ENV=#{fetch(:rails_env, 'production')} alchemy:db:import"
    ssh_cmd = "#{ssh_command(server)} '#{import_cmd}'"
    "#{database_dump_command(database_config['adapter'])} | #{ssh_cmd}"
  end

  # Sends files of given type via rsync to server
  def send_files(type, server)
    raise "No server given" if !server
    FileUtils.mkdir_p "./uploads/#{type}"
    system "rsync --progress -rue 'ssh -p #{ssh_port(server)}' uploads/#{type} #{server.user}@#{server.hostname}:#{shared_path}/uploads/"
  end

  def get_files(type, server)
    raise "No server given" if !server
    FileUtils.mkdir_p "./uploads"
    puts "Importing #{type}. Please wait..."
    system "rsync --progress -rue 'ssh -p #{ssh_port(server)}' #{server.user}@#{server.hostname}:#{shared_path}/uploads/#{type} ./uploads/"
  end

  private

  def ssh_command(server)
    "ssh -p #{ssh_port(server)} #{server.user}@#{server.hostname}"
  end

  def ssh_port(server)
    server.port ? server.port : 22
  end
end
