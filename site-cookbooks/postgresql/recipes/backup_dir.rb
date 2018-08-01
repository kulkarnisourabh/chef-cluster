#Recipes to backup current /var/lib/postgresql/9.5/main to ./main-back and create recovery file
 
service 'postgresql' do
  extend PostgresqlCookbook::Helpers
  service_name lazy { platform_service_name }
  supports stop: true, status: false, reload: false
  action :nothing
end

 bash 'generate_main_backup' do
    user 'postgres'
    code <<-EOH
    cd /var/lib/postgresql/9.5/
    mv main main-back
    mkdir main/
    chmod 700 main/
    chown -R postgres:postgres main/
    EOH
  end

  template '/var/lib/postgresql/9.5/recovery.conf' do
    source 'recovery.conf.erb'
    owner 'postgres'
    group 'postgres'
    mode '0600'
  end
