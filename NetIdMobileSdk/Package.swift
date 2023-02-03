// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NetIdMobileSdk",
    defaultLocalization: "DE",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "NetIdMobileSdk",
            targets: ["NetIdMobileSdk"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/openid/AppAuth-iOS.git", .upToNextMajor(from: "1.5.0"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "NetIdMobileSdk",
            dependencies: [.product(name: "AppAuth", package: "AppAuth-iOS")],
            path: "NetIdMobileSdk"),
        .testTarget(
            name: "NetIdMobileSdkTests",
            dependencies: ["NetIdMobileSdk"]),
    ]
)
