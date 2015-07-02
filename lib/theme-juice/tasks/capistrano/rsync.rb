# encoding: UTF-8

namespace :rsync do

  after :stage, :precompile do
    run_locally do
      within fetch(:rsync_stage) do
        fetch(:rsync_install, []).each { |t| execute t }
      end
    end
  end

  after :precompile, :ignore do
    run_locally do
      within fetch(:rsync_stage) do
        fetch(:rsync_ignore, []).each { |f| execute :rm, f }
      end
    end
  end

  after "deploy:finished", :clean do
    run_locally do
      execute :rm, "-rf", fetch(:rsync_stage)
    end
  end

  namespace :prepare do

    before "deploy:check:directories", :directories do
      on roles(:app) do
        within fetch(:deploy_to) do
          execute :mkdir, "-p", fetch(:rsync_cache)
        end
      end
    end

    before "deploy:check:linked_files", :files do
      on roles(:app) do
        fetch(:linked_files).each { |f| execute :touch, shared_path.join(f) }
      end
    end
  end
end
