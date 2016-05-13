#
# Cookbook Name:: scale_chef_client
# Recipe:: default
#
# Copyright 2016, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

package 'chef' do
  action :upgrade
end

directory '/etc/chef' do
  owner 'root'
  group 'root'
  mode '0755'
end

ruby_block 'reload_client_config' do
  block do
    Chef::Config.from_file('/etc/chef/client.rb')
  end
  action :nothing
end

template '/etc/chef/client.rb' do
  owner 'root'
  group 'root'
  mode '0644'
  notifies :create, 'ruby_block[reload_client_config]', :immediately
end

template '/etc/chef/runlist.json' do
  owner 'root'
  group 'root'
  mode '0644'
end

node.default['fb_cron']['jobs']['chef'] = {
  'time' => '*/15 * * * *',
  'command' => '/var/chef/repos/scale-chef/scripts/chefctl -i'
}