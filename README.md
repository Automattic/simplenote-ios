# Simplenote for iOS
A Simplenote client for iOS. Learn more about Simplenote at [Simplenote.com](https://simplenote.com).


## Development Requirements

* [CocoaPods](https://cocoapods.org/).
* [Xcode](https://developer.apple.com/xcode/).


## Setup Credentials

Simplenote is powered by the [Simperium Sync'ing protocol](https://www.simperium.com). We distribute **testing credentials** that help us authenticate your application, and verify that the API calls being made are valid.

In order to create your own Simperium.com Application, please, [head over to our website](https://www.simperium.com) and signup for free.

After you've created your own Simperium application, copy the sample config. For example:

```
cp Simplenote/config-demo.plist Simplenote/config.plist
```

Then edit the new config.plist file and change the SPSimperiumAppID and SPSimperiumApiKey fields to the correct values for your new app.

This will allow you to compile and run the app on a device or a simulator.


## Running

1. Clone the repo: `git clone https://github.com/Automattic/simplenote-ios.git`
2. Run `pod install` from the root directory, and then open `Simplenote.xcworkspace` file in Xcode.
3. Sign up for a new account within the app. Use the account for **testing purposes only** as all note data will be periodically cleared out on the server.

_Note: Simplenote API features such as sharing and publishing will not work with development builds._


## Contributing

Follow the same guidelines as [WordPress for iOS](https://make.wordpress.org/mobile/handbook/pathways/ios/how-to-contribute/).

## Acknowledgements
This app utilizes the [iA Writer Duospace font](https://github.com/iaolo/iA-Fonts/tree/master/iA%20Writer%20Duospace) for the editor with the monospace option enabled.

Happy noting!
