# Simplenote for iOS
A Simplenote client for iOS. Learn more about Simplenote at [Simplenote.com](https://simplenote.com).

## Development Requirements
* A Simperium account. [Sign up here](https://simperium.com/signup/)
* A Simperium Application ID and key. [Create a new app here](https://simperium.com/app/new/)

## Running

1. Clone the repo: `git clone https://github.com/Automattic/simplenote-ios.git`
2. Make a copy of `config.example.plist` and rename it to `config.plist`.
3. Edit `config.plist` and add your app id and key:

```
    <dict>
        <key>SPSimperiumAppID</key>
        <string>your-app-id</string>
        <key>SPSimperiumApiKey</key>
        <string>your-api-key</string>
    </dict>
```

3: Run [`pod install`](https://cocoapods.org/) from the root directory, and then open `Simplenote.xcworkspace` file in Xcode.

_Note: Simplenote API features such as sharing and publishing will not work with development builds._

## Contributing

Follow the same guidelines as [WordPress for iOS](https://make.wordpress.org/mobile/handbook/pathways/ios/how-to-contribute/).

Happy noting!
