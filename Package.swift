// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "KnxBasics2",
    platforms: [
      .macOS("10.14")
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "KnxBasics2",
            targets: ["KnxBasics2"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/SwiftyBeaver/SwiftyBeaver.git", .branch("xcode11-beta")), //.upToNextMajor(from: "1.7.0")),
        .package(url: "https://github.com/TrondKjeldas/CocoaAsyncSocket.git", .branch("master")) // .upToNextMajor(from: "7.6.3"))

    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "KnxBasics2",
            dependencies: ["SwiftyBeaver", "CocoaAsyncSocket"]),
        .testTarget(
            name: "KnxBasics2Tests",
            dependencies: ["KnxBasics2"]),
    ]
)
