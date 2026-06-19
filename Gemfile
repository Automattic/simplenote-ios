# frozen_string_literal: true

source 'https://rubygems.org'

gem 'danger-dangermattic', '~> 1.3'
gem 'fastlane', '~> 2'
gem 'fastlane-plugin-firebase_app_distribution', '~> 0.10'
gem 'fastlane-plugin-sentry', '~> 2.5'
gem 'fastlane-plugin-wpmreleasetoolkit', '~> 14.7'

# Pinned to pull in the fix for GHSA-c4rq-3m3g-8wgx (CSS selector ReDoS).
# Drop once `fastlane-plugin-wpmreleasetoolkit` moves to >= 14.4.1, whose
# gemspec carries this floor transitively.
gem 'nokogiri', '~> 1.19'

group :screenshots, optional: true do
  gem 'rmagick', '~> 3.2.0'
end
