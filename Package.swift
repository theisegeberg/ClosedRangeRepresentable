// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "ClosedRangeRepresentable",
    products: [
        .library(
            name: "ClosedRangeRepresentable",
            targets: ["ClosedRangeRepresentable"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "ClosedRangeRepresentable",
            dependencies: []),
        .testTarget(
            name: "ClosedRangeRepresentableTests",
            dependencies: ["ClosedRangeRepresentable"]),
    ]
)
