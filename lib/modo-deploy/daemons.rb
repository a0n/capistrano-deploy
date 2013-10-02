module ModoDeploy
  module Daemons
    def self.load_into(configuration)
      configuration.load do
        namespace :daemons do
          desc "Setup Daemons initializer"
          task :setup, roles: :app do
            template "daemons_init.erb", "/tmp/daemons_init_#{application}"
            run "chmod +x /tmp/daemons_init_#{application}"
            run "#{sudo} mv /tmp/daemons_init_#{application} /etc/init.d/daemons_#{application}"
            run "#{sudo} update-rc.d -f daemons_#{application} defaults"
          end
          after "deploy:setup", "daemons:setup"

          %w[start stop restart status].each do |command|
            desc "#{command} daemons"
            task command, roles: :app do
              run "cd #{current_path}; RAILS_ENV=#{rails_env} bundle exec lib/daemons/daemons #{command}"
            end
            after "deploy:#{command}", "daemons:#{command}"
          end
        end
      end
    end
  end
end