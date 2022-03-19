// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "XCActivityLogParser",
    products: [
        .executable(
            name: "XCActivityLogParserApp",
            targets: ["XCActivityLogParserApp"]),
        .library(
            name: "XCActivityLogParser",
            targets: ["XCActivityLogParser"]),
        .library(
            name: "IDEActivityModel",
            targets: ["IDEActivityModel"]),
    ],
    dependencies: [
        .package(url: "https://github.com/1024jp/GzipSwift", from: "5.1.0"),
    ],
    targets: [
        .target(
            name: "XCActivityLogParser",
            dependencies: []),
        .target(
            name: "IDEActivityModel",
            dependencies: ["XCActivityLogParser", .product(name: "Gzip", package: "GzipSwift")]),
        .executableTarget(
            name: "XCActivityLogParserApp",
            dependencies: ["IDEActivityModel"]),
        .testTarget(
            name: "XCActivityLogParserTests",
            dependencies: ["XCActivityLogParser"],
            path: "Tests"),
    ]
)
