source 'https://github.com/CocoaPods/Specs.git'

inhibit_all_warnings!
use_frameworks!

platform :ios, '10.0'
workspace 'Simplenote.xcworkspace'

plugin 'cocoapods-repo-update'

# Main
#
abstract_target 'Automattic' do
	# Shared Dependencies
	#
	pod 'SAMKeychain', '1.5.2'

	# Main Target
	#
	target 'Simplenote' do
		# Third Party
		#
		pod '1PasswordExtension', '1.8.5'
		pod 'Gridicons', '~> 0.18'
		pod 'HockeySDK', '5.1.4'
		pod 'SVProgressHUD', '2.2.5'
		pod 'Fabric', '1.7.0'
		pod 'Crashlytics', '3.9'

		# Automattic
		#
		pod 'Automattic-Tracks-iOS', '0.3.4'
		pod 'Simperium', '0.8.19'
		pod 'WordPress-AppbotX', :git => 'https://github.com/wordpress-mobile/appbotx.git', :commit => '479d05f7d6b963c9b44040e6ea9f190e8bd9a47a'
		pod 'WordPress-Ratings-iOS', '0.0.2'

		# Testing Target
		#
		target 'SimplenoteTests' do
			inherit! :search_paths
		end
	end

	# Extension Target
	#
	target 'SimplenoteShare'
end
