def template(from, to)
  erb = File.read(File.expand_path("../templates/#{from}", __FILE__))
  put ERB.new(erb).result(binding), to
end

def set_default(name, *args, &block)
  set(name, *args, &block) unless exists?(name)
end

module ModoDeploy
  module Unicorn
    def self.load_into(configuration)
      configuration.load do
        set_default(:unicorn_user) { user }
        set_default(:unicorn_pid) { "#{current_path}/tmp/pids/unicorn.pid" }
        set_default(:unicorn_config) { "#{shared_path}/config/unicorn.rb" }
        set_default(:unicorn_log) { "#{shared_path}/log/unicorn.log" }
        set_default(:unicorn_workers, 2)

        namespace :unicorn do
          desc "Generating Unicorn Configuration, Generate and Activate System Startup Script in /etc/init.d/unicorn_#{application}"
          task :setup, roles: :app do
            run "mkdir -p #{shared_path}/config"
            template "unicorn.rb.erb", unicorn_config
            template "unicorn_init.erb", "/tmp/unicorn_init"
            run "chmod +x /tmp/unicorn_init"
            run "#{sudo} mv /tmp/unicorn_init /etc/init.d/unicorn_#{application}"
            run "#{sudo} update-rc.d -f unicorn_#{application} defaults"
          end
          after "deploy:setup", "unicorn:setup"

          %w[start stop restart].each do |command|
            desc "#{command} unicorn"
            task command, roles: :app do
              run "service unicorn_#{application} #{command}"
            end
            after "deploy:#{command}", "unicorn:#{command}"
          end
        end
      end
    end
  end
end