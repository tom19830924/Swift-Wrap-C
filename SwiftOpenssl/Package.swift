// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "SwiftOpenssl",
    products: [
        .library(name: "SwiftOpenssl", targets: ["SwiftOpenssl"]),
    ],
    dependencies: [
        .package(path: "../Copenssl"),
    ],
    targets: [
        .target(name: "SwiftOpenssl", dependencies: ["Copenssl"]),
    ]
)
