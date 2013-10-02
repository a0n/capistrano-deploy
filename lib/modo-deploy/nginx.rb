def template(from, to)
  erb = File.read(File.expand_path("../templates/#{from}", __FILE__))
  put ERB.new(erb).result(binding), to
end

def set_default(name, *args, &block)
  set(name, *args, &block) unless exists?(name)
end

module ModoDeploy
  module Nginx
    def self.load_into(configuration)
      configuration.load do
        namespace :nginx do 
          desc "Install the latest stable release of nginx"
          task :install, roles: :web do 
            run "#{sudo} apt-get -y update"
            run "#{sudo} apt-get -y install nginx"
          end
          after "deploy:install", "nginx:install"

          desc "Setup nginx configuration for this application"
          task :setup,  roles: :web do 
            template "nginx_unicorn.conf.erb", "/tmp/nginx_conf"
            run "#{sudo} mv /tmp/nginx_conf /etc/nginx/sites-enabled/#{application}"
            restart
          end
          after "deploy:setup", "nginx:setup"

          %w[start stop restart].each do |command|
            desc "#{command} nginx"
            task command, roles: :web do 
              run "#{sudo} service nginx #{command}"
            end
          end
        end
      end
    end
  end
end
