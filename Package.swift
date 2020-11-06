// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "swift-httpd",
    products: [
        .executable(
            name: "swift-httpd",
            targets: ["swift-httpd"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "swift-httpd",
            dependencies: [],
            path: "./Sources/swift-httpd",
            sources: [ "http.swift", "main.swift", "network.swift", "threadpool.swift" ]),
    ]
)
