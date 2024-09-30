// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Copenssl",
    products: [
        .library(name: "Copenssl", targets: ["Copenssl"]),
    ],
    targets: [
        .systemLibrary(name: "Copenssl", pkgConfig: "openssl", providers: [.brew(["openssl"])]),
    ]
)
