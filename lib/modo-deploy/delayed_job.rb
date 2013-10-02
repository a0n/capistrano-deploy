def remote_file_exists?(full_path)
  'true' ==  capture("if [ -e #{full_path} ]; then echo 'true'; fi").strip
end

module ModoDeploy
  module DelayedJob
    def self.load_into(configuration)
      configuration.load do


        namespace :delayed_job do
          desc "Setup Delayed Job initializer"
          task :setup, roles: :app do
            template "delayed_job_init.erb", "/tmp/delayed_job_init_#{application}"
            run "chmod +x /tmp/delayed_job_init_#{application}"
            run "#{sudo} mv /tmp/delayed_job_init_#{application} /etc/init.d/delayed_job_#{application}"
            run "#{sudo} update-rc.d -f delayed_job_#{application} defaults"
          end
          after "deploy:setup", "delayed_job:setup"


          %w[start stop restart status].each do |command|
            desc "#{command} delayed_job"
            task command, roles: :web do 
              if remote_file_exists?("#{current_path}/bin/delayed_job")
                delayed_job_path = 'bin/delayed_job'
              else
                delayed_job_path = 'script/delayed_job'
              end

              run "cd #{current_path}; RAILS_ENV=#{rails_env} #{delayed_job_path} #{command}"
            end
          end

          after "deploy:restart", "delayed_job:restart"
          after "deploy:start", "delayed_job:start"
          after "deploy:stop", "delayed_job:stop"
        end
      end
    end
  end
end