## Introduction

capistrano-asgroup is a
[Capistrano](https://github.com/capistrano/capistrano) plugin designed
to simplify the task of deploying to infrastructure hosted on [Amazon
EC2](http://aws.amazon.com/ec2/). It was completely inspired by the
[capistrano-ec2group](https://github.com/logandk/capistrano-ec2group)
and
[capistrano-ec2tag](https://github.com/douglasjarquin/capistrano-ec2tag)
plugins, to which all credit is due.

Both of the prior plugins gave you "a way" to deploy using Capistrano to
AWS Auto Scaling groups but both required you to do so in a
non-straightforward manner by putting your Auto Scaling group in its own
security group or by providing a unique tag for your Auto Scaling group.
This plugin simply takes the name of the Auto Scaling group and uses
that to find the Auto Scaling instances that it should deploy to.  It
will work with straight up hand created Auto Scaling groups (exact match
of the AS group name) or with Cloud Formation created Auto Scaling
groups (looking for the name in the Cloud Formation format).

## Installation

### Set the Amazon AWS Credentials

In order for the plugin to list out the hostnames of your AWS Auto Scaling instances, it
will need access to the Amazon AWS API.  It is recommended to use IAM to create credentials
with limited capabilities for this type of purpose. Specify the following in your
Capistrano configuration:

You can use aws-sdk credentials described in [AWS docs](http://docs.aws.amazon.com/sdkforruby/api/index.html)

```ruby
set :aws_access_key_id, ENV['AWS_ACCESS_KEY_ID']
set :aws_secret_access_key, ENV['AWS_SECRET_ACCESS_KEY']
```

Or you can skip this if you have `~/.aws/credentials` configured. If you
want to select a specific profile for your credentials you can set:

```ruby
set :aws_profile_name, 'my_profile'
```

### Get the gem

The plugin is distributed as a Ruby gem.

Add the following to your Gemfile:

```ruby
source "https://packagecloud.io/Empatico/packages" do
  gem "capistrano-asgroup"
end
```

Install the gems in your manifest using:

```bash
bundle install
```

## Usage

### Configure Capistrano

Add the gem to your `Capfile`

```ruby
require 'capistrano/asgroup'
```

Then configure your AWS settings in your `config/` file.

```ruby
set :aws_region, 'eu-west-1' # set the region of AWS
set :asgroup_use_private_ips, true
set :aws_profile_name, 'profile_name'
```

The `asgroup_use_private_ips` is needed when deploying through a NAT
Gateway into a VPC. It uses the instance's private IP addresses rather
than their public addresses.

Then replace your `role` or similar statement with a statement like:

```ruby
Capistrano::Asgroup.addInstances("<my-autoscale-group-name>"[, roles:
<role>])
```

So instead of:

```ruby
task :production do
  role :web, 'mysever1.example.com','myserver2.example.com'
  logger.info 'Deploying to the PRODUCTION environment!'
end
```

You would do:

```ruby
task :production do
  Capistrano::Asgroup.addInstances("my-asg-name", roles: 'web')
  logger.info 'Deploying to the PRODUCTION environment!'
end
```

### Add by tag

You can also add instances via the ASG's tagging system.

```ruby
Capistrano::Asgroup.addInstancesByTag("tagname", "tagvalue", {other: params})
```

## License

This a continuation of Thomas Verbiscer's
[capistrano-asgroup](https://github.com/tverbiscer/capistrano-asgroup),
which was extended again by [Piotr Jasiulewicz](https://github.com/teu).

Originally developed by:
[Thomas Verbiscer](http://tom.verbiscer.com/), released under the MIT License
