source 'https://cdn.cocoapods.org/'

unless ['BUNDLE_BIN_PATH', 'BUNDLE_GEMFILE'].any? { |k| ENV.key?(k) }
	raise 'Please run CocoaPods via `bundle exec`'
end

inhibit_all_warnings!
use_frameworks!

platform :ios, '12.0'
workspace 'Simplenote.xcworkspace'

plugin 'cocoapods-repo-update'

# Main
#
abstract_target 'Automattic' do

	# Main Target
	#
	target 'Simplenote' do
		# Third Party
		#
		pod 'Gridicons', '~> 0.18'
		pod 'AppCenter', '~> 2.5.1'
		pod 'AppCenter/Distribute', '~> 2.5.1'

		# Automattic
		#
		pod 'Automattic-Tracks-iOS', '~> 0.6'
#		pod 'Automattic-Tracks-iOS', :git => 'https://github.com/Automattic/Automattic-Tracks-iOS.git', :branch => 'add/support-for-tracking-crashes'
		pod 'Simperium', '1.8.0'
		pod 'WordPress-Ratings-iOS', '0.0.2'

		# Testing Target
		#
		target 'SimplenoteTests' do
			inherit! :search_paths
		end
	end

	# Extension Target
	#
	target 'SimplenoteShare' do
		# Third Party
		#
	    pod 'ZIPFoundation', '~> 0.9.9'
	end
end


# Post Install
#
post_install do |installer|
  # Remove min deploy target to clean up build warnings.
  # See: https://stackoverflow.com/a/64048124
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
    end
  end
end
