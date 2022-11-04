# frozen_string_literal: true

source 'https://rubygems.org'
gem 'cocoapods', '~> 1.10'
gem 'fastlane', '~> 2'
gem 'fastlane-plugin-appcenter', '~> 1.11'
gem 'fastlane-plugin-sentry', '~> 1.6'
gem 'fastlane-plugin-wpmreleasetoolkit', '~> 5.0'
gem 'rubocop', '~> 1.38'

group :screenshots, optional: true do
  gem 'rmagick', '~> 3.2.0'
end

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)
