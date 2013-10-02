module ModoDeploy
  module Git
    def self.load_into(configuration)
      configuration.load do
        set :scm, "git"
        set :scm_command, "git"
        set :repository, "git@bitbucket.org:modomoto/#{application}.git"
        set :scm_verbose, true
      end
    end
  end
end
