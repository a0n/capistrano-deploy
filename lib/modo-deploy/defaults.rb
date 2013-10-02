def set_default(name, *args, &block)
  set(name, *args, &block) unless exists?(name)
end

module ModoDeploy
  module Defaults
    def self.load_into(configuration)
      configuration.load do
        set_default(:user, "modomoto")
        set_default(:deploy_to, "/home/#{user}/#{application}")
      end  
    end
  end
end
