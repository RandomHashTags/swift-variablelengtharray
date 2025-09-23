// swift-tools-version:6.1

import PackageDescription

let package = Package(
    name: "swift-variablelengtharray",
    products: [
        .library(
            name: "VariableLengthArray",
            targets: ["VariableLengthArray"]
        )
    ],
    traits: [
        .default(enabledTraits: ["Join"]),
        .trait(
            name: "Join",
            description: "Enables functionality to join Variable Length Arrays."
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
