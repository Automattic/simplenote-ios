source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '9.0'
inhibit_all_warnings!
use_frameworks!

# Main
#
abstract_target 'Automattic' do
	# Shared Dependencies
	#
	pod 'SSKeychain', '1.2.2'

	# Main Target
	#
	target 'Simplenote' do
		# Third Party
		#
		pod '1PasswordExtension', '1.1.2'
		pod 'GoogleAnalytics', '3.14.0'
		pod 'HockeySDK', '~>3.8.0'
		pod 'hoedown', '~>3.0.3'
		pod 'SVProgressHUD', '1.1.2'
		pod 'Fabric', '1.6.7'
		pod 'Crashlytics', '3.7.0'

		# Automattic
		#
		pod 'Automattic-Tracks-iOS', :git => 'https://github.com/Automattic/Automattic-Tracks-iOS.git', :tag => '0.1.0'
		pod 'Simperium', '0.8.17'
		pod 'WordPress-AppbotX', :git => 'https://github.com/wordpress-mobile/appbotx.git', :commit => '479d05f7d6b963c9b44040e6ea9f190e8bd9a47a'
		pod 'WordPress-Ratings-iOS', '0.0.2'
	end

	# Extension Target
	#
	target 'SimplenoteShare'
end
