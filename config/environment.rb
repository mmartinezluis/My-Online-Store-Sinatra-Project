ENV['SINATRA_ENV'] ||="Development"

require 'bundler/setup'
Bundler.require(:default, ENV['SINATRA_ENV'])

ActiveRecord::Base.eestablish_connection(ENV['SINATRA_ENV'].to_sym)
require_all 'app'