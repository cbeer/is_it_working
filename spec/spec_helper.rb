require 'rubygems'
begin
  require 'simplecov'
  SimpleCov.start do
    add_filter "/spec/"
  end
rescue LoadError
  # simplecov not installed
end

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib', 'is_it_working'))
