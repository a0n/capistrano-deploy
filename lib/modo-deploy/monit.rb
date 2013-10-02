module ModoDeploy
  module Monit
    def self.load_into(configuration)
      configuration.load do
        namespace :monit do
          desc "Install Monit"
          task :install do
            run "#{sudo} apt-get -y install monit"
          end
          after "deploy:install", "monit:install"

          desc "Setup all Monit configuration"
          task :setup do
            monit_config "monitrc", "/etc/monit/monitrc"
            nginx
            unicorn  
            delayed_job
            sqs_queue
            syntax
            reload
          end
          after "deploy:setup", "monit:setup"


          task(:nginx, roles: :web) { monit_config "nginx" }
          task(:unicorn, roles: :app) { monit_config "unicorn" }
          task(:delayed_job, roles: :app) { monit_config "delayed_job" }
          task(:sqs_queue, roles: :app) { monit_config "sqs_queue" }

          %w[start stop restart syntax reload].each do |command|
            desc "Run Monit #{command} script"
            task command do
              run "#{sudo} service monit #{command}"
            end
          end

          def monit_config(name, destination = nil)
            destination ||= "/etc/monit/conf.d/#{name}_#{application}.conf"
            template "monit/#{name}.erb", "/tmp/monit_#{name}"
            run "#{sudo} mv /tmp/monit_#{name} #{destination}"
            run "#{sudo} chown root #{destination}"
            run "#{sudo} chmod 600 #{destination}"
          end

        end
      end
    end
  end
end

