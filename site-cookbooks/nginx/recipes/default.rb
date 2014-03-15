
package "nginx" do
  action :install
end

package "php5-mysql" do
  action :install
end

package "php5-fpm" do
  action :install
end

service "php5-fpm" do
  supports :status => true, :restart => true, :reload => true
  action [:enable, :reload]
end

template "nginx.conf" do
  path "/etc/nginx/nginx.conf"
  source "nginx.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, "service[nginx]"
end

service "nginx" do
  supports :status => true, :restart => true, :reload => true
  action [:enable, :restart]
end

