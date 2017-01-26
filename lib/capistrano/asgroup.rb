require 'capistrano/asgroup/version'
require 'rubygems'
require 'aws-sdk'
require 'capistrano'

module Capistrano
  module Asgroup
    def self.setup
      if nil == fetch(:asgroup_use_private_ips)
        set :asgroup_use_private_ips, false
      end

      if nil == fetch(:aws_profile_name)
        set :aws_profile_name, "default"
      end

      credentials = Aws::SharedCredentials.new(profile_name: fetch(:aws_profile_name))
      @as_api = Aws::AutoScaling::Client.new(
        region: fetch(:aws_region),
        credentials: credentials
      )
      @ec2_api ||= Aws::EC2::Client.new(
        region: fetch(:aws_region),
        credentials: credentials
      )
    end

    # Adds Capistrano servers based on instance tag k/v
    def self.addInstancesByTag(tagName, tagValue, *args)
      @instance ||= new
      @instance.addInstancesByTag(tagName, tagValue, *args)
    end

    def addInstancesByTag(tagName, tagValue, *args)
      if nil == fetch(:asgroup_use_private_ips)
        set :asgroup_use_private_ips, false
      end

      @ec2DescInst = @ec2_api.describe_instances(filters:[
        name: "tag:#{tagName}", values: [tagValue]
      ])

      @ec2DescInst[:reservations].each do |reservation|
        #remove instances that are either not in this asGroup or not in the "running" state
        reservation[:instances].delete_if{ |a| a[:state][:name] != "running" }.each do |instance|
          puts "Found tagged #{tagName}:#{tagValue} instance, ID: #{instance[:instance_id]} in VPC: #{instance[:vpc_id]}"
          if true == fetch(:asgroup_use_private_ips)
            server(instance[:private_ip_address], *args)
          else
            server(instance[:public_ip_address], *args)
          end

        end
      end
    end
    # Adds Capistrano servers based on the given (part of) name of an AWS autoscaling group
    # Only selects instances that are in "running" state, ignoring starting up and terminating instances
    # Params:
    # +which+:: part or full name of the autoscaling group
    # +*args+:: arguments passed to Capistrano::server method
    def self.addInstances(which, *args)
      @instance ||= new
      @instance.addInstances(which, *args)
    end

    def addInstances(which, *args)
      if nil == fetch(:asgroup_use_private_ips)
        set :asgroup_use_private_ips, false
      end

      # Get descriptions of all the Auto Scaling groups
      @autoScaleDesc = @as_api.describe_auto_scaling_groups
      @asGroupInstanceIds = Array.new()
      # Find the right Auto Scaling group
      @autoScaleDesc[:auto_scaling_groups].each do |asGroup|
        # Look for an exact name match or Cloud Formation style match (<cloud_formation_script>-<as_name>-<generated_id>)
        if asGroup[:auto_scaling_group_name] == which or asGroup[:auto_scaling_group_name].scan("{which}").length > 0
          # For each instance in the Auto Scale group
          asGroup[:instances].each do |asInstance|
            @asGroupInstanceIds.push(asInstance[:instance_id])
          end
        end
      end

      # Get descriptions of all the EC2 instances
      @ec2DescInst = @ec2_api.describe_instances(instance_ids: @asGroupInstanceIds)
      # figure out the instance IP's
      @ec2DescInst[:reservations].each do |reservation|
        #remove instances that are either not in this asGroup or not in the "running" state
        reservation[:instances].delete_if{ |a| not @asGroupInstanceIds.include?(a[:instance_id]) or a[:state][:name] != "running" }.each do |instance|
          puts "Found ASG #{which} Instance ID: #{instance[:instance_id]} in VPC: #{instance[:vpc_id]}"
          if true == fetch(:asgroup_use_private_ips)
            server(instance[:private_ip_address], *args)
          else
            server(instance[:public_ip_address], *args)
          end

        end
      end
    end

  end
end
