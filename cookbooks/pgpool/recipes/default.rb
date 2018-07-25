#
# Cookbook Name:: pgpool
# Recipe:: default
#
# Copyright 2015, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

package node['pgpool']['config']['package_name'] do
  action :install
end

group node['pgpool']['group'] do
  action :create
end

user node['pgpool']['user'] do
  action :create
  gid node['pgpool']['group']
end

%w(pgpool pcp pool_hba).each do |f|
  template "#{node['pgpool']['config']['dir']}/#{f}.conf" do
    owner 'root'
    group 'root'
    mode 0644
    notifies :restart, 'service[pgpool]', :delayed
  end
end

%w(
  logdir
  socket_dir
  pcp_socket_dir
).each do |dir|
  directory node['pgpool']['pgconf'][dir] do
    action :create
    owner node['pgpool']['user']
    group node['pgpool']['group']
    mode 0755
  end
end

service 'pgpool' do
  service_name node['pgpool']['service']
  action [ :enable, :start ]
end
