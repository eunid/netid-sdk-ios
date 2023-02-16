// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

/*! @file Package.swift
   @brief AppAuth iOS SDK
   @copyright
       Copyright 2022 European netID Foundation (https://enid.foundation)
   @copydetails
       Licensed under the Apache License, Version 2.0 (the "License");
       you may not use this file except in compliance with the License.
       You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

       Unless required by applicable law or agreed to in writing, software
       distributed under the License is distributed on an "AS IS" BASIS,
       WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
       See the License for the specific language governing permissions and
       limitations under the License.
*/

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
            path: "Sources/NetIdMobileSdk",
            resources: [
		.process("assets"),
            ],
            swiftSettings: [
              .define("USES_SWIFT_PACKAGE_MANAGER")
            ]),
        .testTarget(
            name: "NetIdMobileSdkTests",
            dependencies: ["NetIdMobileSdk"]),
    ]
)
