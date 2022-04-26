// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "simpleRxtableDemo",
    dependencies: [
        .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "6.0.0"),
        .package(url: "https://github.com/RxSwiftCommunity/RxDataSources.git", from: "5.0.0")
    ],
    targets: [
        .target(
            name: "simpleRxtableDemo",
            dependencies: ["RxSwift","RxCocoa","RxDataSources"]),
        .testTarget(
            name: "simpleRxtableDemoTests",
            dependencies: ["simpleRxtableDemo"]),
    ]
)
