# Capistrano Tasks for Alchemy CMS

Adds the Alchemy `uploads` folder to Capistranos `linked_dirs` array in order to survive deployments.

In addition, it offers several tasks to synchronize your uploads folder and your database between environments.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'capistrano-alchemy', '~> 1.0', group: :development, require: false
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install capistrano-alchemy

If your application is not prepared for capistrano yet, you need to do so now:

    $ bundle exec cap install

You have to add the `Capistrano::Alchemy` and Rails specific tasks to your `Capfile`

```ruby
require 'capistrano/rails'
require 'capistrano/alchemy'
```

## Usage


### Upgrade Alchemy

We have a task to run the alchemy upgrader on your servers.

```shell
$ bundle exec cap staging alchemy:upgrade
```

**CAUTION:** Please be sure to run the upgrader locally before running this untested on your production system!

Cloning the production data to your local dev env is advised before running the upgrader. This can easily be done with
the next command.

### Synchronize your data

Alchemy Capistrano receipts offer much more then only deployment related tasks. We also have tasks to make your local development easier. To get a list of all receipts type:

```shell
$ bundle exec cap -T alchemy
```

#### Import data from server

```shell
$ bundle exec cap staging alchemy:import:all
```

This imports your staging server's data onto your local development machine. This is very handy if you want to clone the current server state. Replace `staging` for `production` if you need the production data.

#### Export data to server

That even works the other way around:

```shell
$ bundle exec cap staging alchemy:export:all
```

**NOTE:** This will **overwrite the database** on your `staging` server. But calm down my dear friend, Alchemy will ask you to perform a backup before overwriting it.

## Contributing

1. Fork it ( https://github.com/[my-github-username]/capistrano-alchemy/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
