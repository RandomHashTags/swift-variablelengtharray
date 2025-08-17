// swift-tools-version:6.0

import PackageDescription

let package = Package(
    name: "swift-variablelengtharray",
    products: [
        .library(
            name: "swift-variablelengtharray",
            targets: ["VariableLengthArray"]
        )
    ],
    targets: [
        .target(
            name: "VariableLengthArray"
        ),
        .testTarget(
            name: "swift-variablelengtharrayTests",
            dependencies: ["VariableLengthArray"]
        )
    ]
)
