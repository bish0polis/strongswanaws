#
# Cookbook Name:: strongswanaws
# Recipe:: server
#

# AWS VPN requires StrongSwan 5.0+
# This in the default in Ubuntu 14.04 and above
package 'strongswan' do
  action :install
end

# This service defined only to recieve notifications
# it runs: sysctl --system
service 'procps' do
  action :nothing
end

@sysctl_ip_fwd = '
# Uncomment the next line to enable packet forwarding for IPv4
net.ipv4.ip_forward=1
'

file '/etc/sysctl.d/60-strongswan.conf' do
  content @sysctl_ip_fwd
  mode '0644'
  owner 'root'
  group 'root'
  # sysctl variables should be re-loaded after a change
  notifies :start, 'service[procps]', :immediately
end

# Grouping gateway configs together is more organized
directory '/etc/ipsec.connections' do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

# Grouping connection templates together is more organized
directory '/etc/ipsec.templates' do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

# StrongSwan will not start if there isn't at least
# one file to include from /etc/ipsec.connections
file '/etc/ipsec.connections/default.conf' do
  content ''
  mode '0644'
  owner 'root'
  group 'root'
end

# StrongSwan will not start if there isn't at least
# one file to include from /etc/ipsec.templates
file '/etc/ipsec.templates/default.conf' do
  content ''
  mode '0644'
  owner 'root'
  group 'root'
end

service 'strongswan' do
  # VPN should start, when the instance boots
  action :enable
end

template '/etc/ipsec.conf' do
  source 'ipsec_conf.erb'
  owner 'root'
  group 'root'
  mode '0644'
  variables('debug' => node['strongswanaws']['debug'])
  notifies :restart, 'service[strongswan]', :delayed
end