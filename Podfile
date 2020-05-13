source 'https://github.com/CocoaPods/Specs.git'

inhibit_all_warnings!
use_frameworks!

platform :ios, '11.0'
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
		pod '1PasswordExtension', '1.8.6'
		pod 'Gridicons', '~> 0.18'
		pod 'AppCenter', '~> 2.3.0' 
		pod 'AppCenter/Distribute', '~> 2.3.0'

		# Automattic
		#
		pod 'Automattic-Tracks-iOS', '~> 0.4'
#		pod 'Automattic-Tracks-iOS', :git => 'https://github.com/Automattic/Automattic-Tracks-iOS.git', :branch => 'add/support-for-tracking-crashes'
		pod 'Simperium', '~> 0.8.27'
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
