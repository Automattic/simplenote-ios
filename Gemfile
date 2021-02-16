source 'https://rubygems.org'
gem 'cocoapods', '~> 1.10'
gem 'cocoapods-repo-update', '~> 0.0.3'
gem 'xcpretty-travis-formatter'
gem 'octokit', "~> 4.0"
gem 'dotenv'
gem 'fastlane', '~> 2'

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)
