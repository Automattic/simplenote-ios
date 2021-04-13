// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "UITestsHelper",
    // iOS 12 is the minimum deployment target for what's currently the only
    // consumer of the package, Simplenote iOS. It might be possible to lower
    // the constraint if necessary.
    platforms: [.iOS(.v12)],
    products: [
        .library(name: "UITestsHelper", targets: ["UITestsHelper"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "UITestsHelper", dependencies: []),
        .testTarget(name: "UITestsHelperTests", dependencies: ["UITestsHelper"]),
    ]
)
