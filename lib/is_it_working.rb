require 'time'
require 'thread'

module IsItWorking
  autoload :Check, File.expand_path("../is_it_working/check.rb", __FILE__)
  autoload :Filter, File.expand_path("../is_it_working/filter.rb", __FILE__)
  autoload :Handler, File.expand_path("../is_it_working/handler.rb", __FILE__)
  autoload :Status, File.expand_path("../is_it_working/status.rb", __FILE__)
  
  # Predefined checks
  autoload :ActionMailerCheck, File.expand_path("../is_it_working/checks/action_mailer_check.rb", __FILE__)
  autoload :ActiveRecordCheck, File.expand_path("../is_it_working/checks/active_record_check.rb", __FILE__)
  autoload :RubydoraCheck, File.expand_path("../is_it_working/checks/rubydora_check.rb", __FILE__)
  autoload :BundlerCheck, File.expand_path("../is_it_working/checks/bundler_check.rb", __FILE__)
  autoload :DalliCheck, File.expand_path("../is_it_working/checks/dalli_check.rb", __FILE__)
  autoload :DirectoryCheck, File.expand_path("../is_it_working/checks/directory_check.rb", __FILE__)
  autoload :EnvCheck, File.expand_path("../is_it_working/checks/env_check.rb", __FILE__)
  autoload :MemcacheCheck, File.expand_path("../is_it_working/checks/memcache_check.rb", __FILE__)
  autoload :PingCheck, File.expand_path("../is_it_working/checks/ping_check.rb", __FILE__)
  autoload :RequestCheck, File.expand_path("../is_it_working/checks/request_check.rb", __FILE__)
  autoload :RsolrCheck, File.expand_path("../is_it_working/checks/rsolr_check.rb", __FILE__)
  autoload :UrlCheck, File.expand_path("../is_it_working/checks/url_check.rb", __FILE__)
end
