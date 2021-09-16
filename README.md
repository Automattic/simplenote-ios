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

SwiftLint is integrated directly into the Xcode project, so lint errors appear as warnings after you build the project

If your code has any style violations, you can try to automatically correct them by running:

`rake lint:autocorrect`

Otherwise you have to fix them manually.

### Open Xcode

Launch the workspace by running the following from the command line:

`rake xcode`

This will ensure any dependencies are ready before launching Xcode.

You can also open the project by double clicking on Simplenote.xcworkspace file, or launching Xcode and choose `File` > `Open` and browse to `Simplenote.xcworkspace`.

Once you have opened Simpleonte iOS in Xcode, depending on your setup, you may need to make a few changes before you can build the app.  In Xcode hit `Command + B` and see if you get any errors.  

If you see `The server SSH fingerprint failed to verify` before you can build Simplenote you will need to mark the app as trusted.  To do this, tap on the warning and hit Trust

If the build fails with an `Authentication failed because the credentials were missing` error most likely you need to update the Swift Packages before being able to build the app. We use Swift Package Manager for some internal dependencies which can be found on Github.  To fetch these packages, connect Xcode to Github by going to Xcode > Preferences > Accounts, then enter your Github account details.  To be able to fetch these dependencies Xcode will need to be connected to a Github account via [SSH](https://docs.github.com/en/github/authenticating-to-github/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)

Once you have trusted the app and the SPM packages are downloaded you should be able to build the app.  Try `Command + B` again and make sure that it builds correctly.

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
