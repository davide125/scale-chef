#
# Cookbook Name:: scale_mailman
# Recipe:: default
#

#TODO: POSTFIX should probably move to a generic postfix cookbook

pkgs = %w{
  httpd
  mod_ssl
  php
  php-gd
  php-mysql
  php-pdo
  php-xml
  python-dns
  python-boto
}
package pkgs do
  action :upgrade
  notifies :restart, 'service[httpd]'
end

directory '/var/www/html/' do
  owner 'root'
  group 'root'
  mode '0755'
end

cookbook_file '/var/www/html/index.html' do
  source 'index.html'
  owner 'root'
  group 'root'
  mode '0644'
end

cookbook_file "#{Chef::Config['file_cache_path']}/mailman-2.1.21-1.fc25.x86_64.rpm" do
  source 'mailman-2.1.21-1.fc25.x86_64.rpm'
  owner 'root'
  group 'root'
  mode '0644'
end

%w{
  httpd.conf
}.each do |conf|
  template "/etc/httpd/conf/#{conf}" do
    owner 'root'
    group 'root'
    mode  '0644'
    notifies :restart, 'service[httpd]'
  end
end

%w{
  default.conf
  ssl-default.conf
  mailman.conf
}.each do |conf|
  template "/etc/httpd/conf.d/#{conf}" do
    owner 'root'
    group 'root'
    mode '0644'
    notifies :restart, 'service[httpd]'
  end
end
#
cookbook_file '/etc/httpd/sf_bundle.crt' do
  cookbook 'scale_apache'
  source 'sf_bundle.crt'
end

package 'mailman' do
  source "#{Chef::Config['file_cache_path']}/mailman-2.1.21-1.fc25.x86_64.rpm"
end

## RESTORE BACKUPS
template '/usr/local/bin/restore-mailman.py' do
  owner 'root'
  group 'root'
  mode  '0755'
end

execute '/usr/local/bin/restore-mailman.py' do
  creates '/var/lib/mailman/lists'
end

template '/usr/local/bin/backup-mailman.sh' do
  owner 'root'
  group 'root'
  mode  '0755'
end

file '/etc/cron.d/mailman' do
  action :delete
end

link '/etc/mailman/sitelist.cfg' do
  to '/var/lib/mailman/data/sitelist.cfg'
end

template '/etc/mailman/mm_cfg.py' do
  source 'mm_cfg.py.erb'
  owner 'root'
  group 'root'
  mode  '0644'
end

node.default['fb_cron']['jobs']['mailman_backups'] = {
  'time' => '0 4,20 * * *',
  'command' => '/usr/local/bin/backup-mailman.sh',
  'user' => 'mailman',
}

node.default['fb_cron']['jobs']['mailman_checkdbs'] = {
  'time' => '0 8 * * *',
  'command' => '/usr/lib/mailman/cron/checkdbs',
  'user' => 'mailman',
}

node.default['fb_cron']['jobs']['mailman_disabled'] = {
  'time' => '0 9 * * *',
  'command' => '/usr/lib/mailman/cron/disabled',
  'user' => 'mailman',
}

node.default['fb_cron']['jobs']['mailman_senddigests'] = {
  'time' => '0 12 * * *',
  'command' => '/usr/lib/mailman/cron/senddigests',
  'user' => 'mailman',
}

node.default['fb_cron']['jobs']['mailman_mailpasswds'] = {
  'time' => '0 5 1 * *',
  'command' => '/usr/lib/mailman/cron/mailpasswds',
  'user' => 'mailman',
}

node.default['fb_cron']['jobs']['mailman_gate_news'] = {
  'time' => '0,5,10,15,20,25,30,35,40,45,50,55 * * * *',
  'command' => '/usr/lib/mailman/cron/gate_news',
  'user' => 'mailman',
}

node.default['fb_cron']['jobs']['mailman_nightly_gzip'] = {
  'time' => '27 3 * * *',
  'command' => '/usr/lib/mailman/cron/nightly_gzip',
  'user' => 'mailman',
}

node.default['fb_cron']['jobs']['mailman_cull_bad_shunt'] = {
  'time' => '30 4 * * *',
  'command' => '/usr/lib/mailman/cron/cull_bad_shunt',
  'user' => 'mailman',
}

include_recipe 'scale_apache::dev'
include_recipe 'scale_mailman::postfix'

service 'mailman' do
  action [:enable, :start]
end

service 'httpd' do
  action [:enable, :start]
end