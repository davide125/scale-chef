#
# Cookbook Name:: scale_reg
# Recipe:: default
#
# Copyright 2016, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

package 'MySQL-python' do
  action :upgrade
end

directory '/var/www' do
  owner 'root'
  group 'root'
  mode '0755'
end

directory '/var/www/html' do
  owner 'root'
  group 'root'
  mode '0755'
end

include_recipe 'scale_apache::common'
include_recipe 'scale_apache::dev'
include_recipe 'fb_apache'

node.default['fb_apache']['modules'] << 'wsgi'
node.default['fb_apache']['extra_configs']['WSGIPythonPath'] = '/var/www/django'

vhost_config = {
  'ServerName' => 'register.socallinuxexpo.org',
  'ServerAdmin' => 'hostmaster@linuxfests.org',
  'DocumentRoot' => '/var/www/html',
  'DirectoryIndex' => 'index.html',
  'Directory /' => {
    'Options' => 'FollowSymLinks',
    'AllowOverride' => 'None',
  },
  'Directory /var/www/html' => {
    'Options' => 'Indexes FollowSymLinks MultiViews',
    'AllowOverride' => 'None',
    'Order' => 'allow,deny',
    'Allow' => 'from all',
    'Require' => 'all granted',
  },
  'Location /server-status' => {
    'SetHandler' => 'server-status',
    'Order' => 'Deny,Allow',
    'Deny' => 'from all',
    'Allow' => 'from localhost',
  },
  'LogLevel' => 'warn',
  'WSGIScriptAlias' => [
    '/ /var/www/django/scalereg/wsgi.py',
  ],
  'Alias' => [
    '/media /var/www/django/static/media',
  ],
  'Directory /var/www/django/static/media' => {
    'Require' => 'all granted',
  },
  'Directory /var/www/django/scalereg' => {
    'Files wsgi.py' => {
      'Require' => 'all granted',
    },
  },
}

node.default['fb_apache']['sites']['*:80'] = vhost_config
{
  'ErrorLog' => '/var/log/httpd/error.log',
  'CustomLog' => '/var/log/httpd/access.log combined',
}.each do |key, val|
  node.default['fb_apache']['sites']['*:80'][key] = val
end

node.default['fb_apache']['sites']['_default_:443'] = vhost_config
{
  'ErrorLog' => '/var/log/httpd/ssl_error.log',
  'CustomLog' => '/var/log/httpd/ssl_access.log combined',
  'SSLEngine' => 'on',
  'SSLCertificateFile' => '/etc/httpd/apache.pem',
  'SSLCertificateChainFile' => '/etc/httpd/gd_bundle.crt',
  'SSLProtocol' => 'all -SSLv2 -SSLv3',
  'FilesMatch "\.(cgi|shtml)$"' => {
    'SSLOptions' => '+StdEnvVars',
  },
  'Directory /var/www/cgi-bin' => {
    'SSLOptions' => '+StdEnvVars',
  },
  'BrowserMatch "MSIE [2-6]"' => 
    'nokeepalive ssl-unclean-shutdown downgrade-1.0 force-response-1.0',
  # MSIE 7 and newer should be able to use keepalive
  'BrowserMatch "MSIE [17-9]"' => 'ssl-unclean-shutdown',
}.each do |key, val|
  node.default['fb_apache']['sites']['_default_:443'][key] = val
end
