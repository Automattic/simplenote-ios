# Simplenote for iOS

A Simplenote client for iOS. Learn more about Simplenote at [Simplenote.com](https://simplenote.com).

## Build Instructions

### Download Xcode

At the moment *Simplenote for iOS* uses Swift 5 and requires Xcode 10.2 or newer. Xcode can be [downloaded from Apple](https://developer.apple.com/downloads/index.action).*

### Third party tools

We use a few tools to help with development. To install or update the required dependencies, run the follow command on the command line:

`rake dependencies`

#### CocoaPods

Simplenote for iOS uses [CocoaPods](http://cocoapods.org/) to manage third party libraries.
Third party libraries and resources managed by CocoaPods will be installed by the `rake dependencies` command above.

#### SwiftLint

We use [SwiftLint](https://github.com/realm/SwiftLint) to enforce a common style for Swift code. The app should build and work without it, but if you plan to write code, you are encouraged to install it. No commit should have lint warnings or errors.

You can set up a Git [pre-commit hook](https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks) to run SwiftLint automatically when committing by running:

`rake git:install_hooks`

This is the recommended way to include SwiftLint in your workflow, as it catches lint issues locally before your code makes its way to Github.

Alternately, a SwiftLint scheme is exposed within the project; Xcode will show a warning if you don't have SwiftLint installed.

Finally, you can also run SwiftLint manually from the command line with:

`rake lint`

If your code has any style violations, you can try to automatically correct them by running:

`rake lint:autocorrect`

Otherwise you have to fix them manually.

### Open Xcode

Launch the workspace by running the following from the command line:

`rake xcode`

This will ensure any dependencies are ready before launching Xcode.

You can also open the project by double clicking on Simplenote.xcworkspace file, or launching Xcode and choose `File` > `Open` and browse to `Simplenote.xcworkspace`.


## Setup Credentials

Simplenote is powered by the [Simperium Sync'ing protocol](https://www.simperium.com). We distribute **testing credentials** that help us authenticate your application, and verify that the API calls being made are valid. Once the Simperium account is created, you can register an app and access the APP ID and necessary API keys.

**⚠️ Please note → We're not accepting any new Simperium accounts at this time.**

After you've created your own Simperium application, run the following command in the terminal in order to copy the sample config:

```
mkdir -p ~/.configure/simplenote-ios/secrets && cp Simplenote/SPCredentials-demo.swift ~/.configure/simplenote-ios/secrets/SPCredentials.swift
```

This will copy the demo SPCredentials file into the correct directory with the basic details for an OSS contributor. Then edit the new `Simplenote/Credentials/SPCredentials.swift` file and change the `simperiumAppID` and `simperiumApiKey` fields to the correct values that appear in your Simperium app.

If the build fails with an "Account Creation Failed" error and Xcode asks for your GitHub credentials most likely you need to update the Swift Packages before being able to build the app. Package issues need to be resolved before you can build the app, so the credentials file is put in place. For this you can setup GitHub under Xcode > Preferences > Accounts, then enter your account and [access token](https://docs.github.com/en/github/authenticating-to-github/keeping-your-account-and-data-secure/creating-a-personal-access-token). If you have 2FA on your GitHub account you won't be able to connect to without the [SSH key.](https://docs.github.com/en/github/authenticating-to-github/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)

This will allow you to compile and run the app on a device or a simulator. Please note that this will only work the Simperium account credentials, no other Simplenote account will work.

_Note: Simplenote API features such as sharing and publishing will not work with development builds._

### Optional

If you want to try the screenshots generation locally, also create your own testing credentials for that target:

```
mkdir -p ~/.configure/simplenote-ios/secrets && cp Simplenote/ScreenshotsCredentials-demo.swift ~/.configure/simplenote-ios/secrets/ScreenshotsCredentials.swift
```

## Style Guidelines

We follow the WordPress iOS Style Guidelines, and we're constantly improving / adopting latest techniques.

- [Swift Standard](https://github.com/wordpress-mobile/swift-style-guide)
- [ObjC Standard](https://github.com/wordpress-mobile/objective-c-style-guide)

## Contributing

Read our [Contributing Guide](CONTRIBUTING.md) to learn about reporting issues, contributing code, and more ways to contribute.

## License

Simplenote for iOS is an Open Source project covered by the [GNU General Public License version 2](LICENSE.md).

Happy noting!
