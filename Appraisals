# Install gems for all appraisal definitions:
#
#     $ appraisal install
#
# To run tests on different versions:
#
#     $ appraisal activerecord_x.x rspec spec

# We need to build up the correct versions based on the Ruby version being run.
# Since not all rails versions are compatible with all ruby versions
require "bundler"

ruby_version = ::Gem::Version.new(RUBY_VERSION)
rails_versions = []

if(ruby_version < ::Gem::Version.new("3.0.0"))
    rails_versions = [[ '6.0', '~> 6.0.0' ]]
elsif(ruby_version < ::Gem::Version.new("3.2.0"))
    rails_versions = [['6.1', '~> 6.1.0'], ['7.0', '~> 7.0.0']]
else
    rails_versions = [['7.1', '~> 7.1.0'], ['7.2', '~> 7.2.0'], ['8.0', '~> 8.0.0']]
end

rails_versions.each do |ver_name, ver_req|
  appraise "rails_#{ver_name}" do
    gem 'actionmailer', ver_req
    gem 'activerecord', ver_req
  end
end

