// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ShortURL",
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/IBM-Swift/Kitura.git", .upToNextMinor(from: "2.5.0")),
        .package(url: "https://github.com/IBM-Swift/HeliumLogger.git", .upToNextMinor(from: "1.7.1")),
        .package(url: "https://github.com/IBM-Swift/Health.git", from: "1.0.0"),
        .package(url: "https://github.com/IBM-Swift/CloudEnvironment.git", from: "8.0.0"),
        ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(name: "ShortURL", dependencies: [ .target(name: "Application"), "Kitura", "HeliumLogger" ]),
        .target(name: "Application", dependencies: [ "Kitura", "Health", "CloudEnvironment"]),
        .testTarget(name: "ApplicationTests" , dependencies: [.target(name: "Application"), "Kitura"])
    ]
)
