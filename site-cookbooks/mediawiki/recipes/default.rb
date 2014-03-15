
include_recipe 'database::mysql'

package "php5-gd" do
  action :install
end

package "php5-intl" do
  action :install
end

package "php5-mysql" do
  action :install
end

package "php5-cli" do
  action :install
end

package "git" do
  action :install
end

execute "install pear mail package" do
  command "pear install mail"
  action :run
  not_if "pear list | awk '/Mail/ { print $1 }'"
end

execute "install pear net_smtp package" do
  command "pear install net_smtp"
  action :run
  not_if "pear list | awk '/Net_SMTP/ { print $1 }'"
end

package "php-apc"

directory "#{node[:php][:ext_conf_dir]}" do
  owner "root"
  group "root"
  mode "0655"
  action :create
  recursive true
end

template "#{node[:php][:ext_conf_dir]}/apc.ini" do
  source "apc.ini.erb"
  owner "root"
  group "root"
  mode "0644"
  variables(:name => "apc", :extensions => ["apc.so"], :directives => {"shm_size" => "256M"})
  action action
end


local_file = "#{Chef::Config[:file_cache_path]}/mediawiki-1.22.2.tar.gz"
unless File.exists?(local_file)
  remote_file local_file do
    source "http://download.wikimedia.org/mediawiki/1.22/mediawiki-1.22.2.tar.gz"
    owner node[:system][:user]
    group node[:system][:group]
    mode 00755
  end
end

directory node[:mediawiki][:directory] do
  owner node[:system][:user]
  group node[:system][:group]
  mode 00755
  action :create
  recursive true
end

execute "untar-mediawiki" do
  cwd node[:mediawiki][:directory]
  command "tar --strip-components 1 -xzf #{local_file}"
  creates "#{node[:mediawiki][:directory]}/api.php"
  user node[:system][:user]
  group node[:system][:group]
end

directory "#{node[:mediawiki][:directory]}/config" do
  owner node[:system][:user]
  group node[:system][:group]
  mode "0755"
  only_if {node[:mediawiki][:access2config_folder]=="true"}
end

directory "#{node[:mediawiki][:directory]}/mw-config" do
  owner node[:system][:user]
  group node[:system][:group]
  mode "0755"
  only_if {node[:mediawiki][:access2config_folder]=="true"}
end

directory "#{node[:mediawiki][:directory]}/config" do
  owner node[:system][:user]
  group node[:system][:group]
  mode "0400"
  only_if {node[:mediawiki][:access2config_folder]=="false"}
end

directory "#{node[:mediawiki][:directory]}/mw-config" do
  owner node[:system][:user]
  group node[:system][:group]
  mode "0400"
  only_if {node[:mediawiki][:access2config_folder]=="false"}
end

::Chef::Recipe.send(:include, Opscode::OpenSSL::Password)

node.set_unless[:mediawiki][:installdbPass] = node[:mysql][:server_root_password]
node.set_unless[:mediawiki][:wgDBpassword]  = secure_password
node.set_unless[:mediawiki][:dbAdminPass]   = secure_password
node.set_unless[:mediawiki][:wgSecretKey]   = secure_password
node.set_unless[:mediawiki][:wgUpgradeKey]  = secure_password

mysql_connection_info = {:host => "localhost",
                         :username => 'root',
                         :password => node[:mysql][:server_root_password]}

mysql_database node[:mediawiki][:wgDBname] do
  connection mysql_connection_info
  action :create
end

node.default['mediawiki']['wgScriptPath'] = ""

execute "set permission on the #{node[:mediawiki][:directory]}" do
  command "chown -R #{node[:system][:user]}:#{node[:system][:group]} #{node[:mediawiki][:directory]}"
  action :run
end

# grant all privileges on all tables for this db
mysql_database_user node[:mediawiki][:wgDBuser] do
  connection mysql_connection_info
  database_name node[:mediawiki][:wgDBname]
  password node[:mediawiki][:wgDBpassword]
  action [:create, :grant]
end

bash "run install script" do
  cwd node[:mediawiki][:directory]
  code <<-EOC
    php maintenance/install.php #{node[:mediawiki][:wikiname]} #{node[:mediawiki][:wgDBpassword]} \
      --pass #{node[:mediawiki][:dbAdminPass]} --scriptpath '/wiki' --lang #{node[:mediawiki][:lang]} \
      --dbname #{node[:mediawiki][:wgDBname]} --dbuser #{node[:mediawiki][:wgDBuser]} --dbpass #{node[:mediawiki][:wgDBpassword]}
  EOC
  creates "#{node[:mediawiki][:directory]}/LocalSettings.php" 
end

template "#{node[:mediawiki][:directory]}/LocalSettings.php" do
  source "LocalSettings.php.erb"
  owner node[:system][:user]
  group node[:system][:group]
  mode "0644"
end

