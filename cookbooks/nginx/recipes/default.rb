package "nginx-extras"

%w{nxensite nxdissite}.each do |nxscript|
  template "/usr/sbin/#{nxscript}" do
    source "#{nxscript}.erb"
    mode 0755
    owner "root"
    group "root"
  end
end

remote_file ::File.join(node[:nginx][:dir], "common.conf") do
  source "common.conf"
  notifies :reload, resources(:service => "nginx")
end

template "#{node[:nginx][:dir]}/nginx.conf" do
  source "nginx.conf.erb"
  owner "root"
  group "root"
  mode 0644
  notifies :reload, "service[nginx]"
end

directory "#{node[:nginx][:web_root]}" do
  owner "root"
  group "root"
  mode "0755"
  action :create
end

node[:nginx][:sites].each do |site|
  nginx_site site do
    enable node[:nginx][:sites_enabled]
  end
end

service "nginx" do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
end
