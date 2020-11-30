// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "LocationPicker",
    products: [
        .library(
            name: "LocationPicker",
            targets: ["LocationPicker"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "LocationPicker",
            dependencies: [],
            path: "LocationPicker",
            exclude: [
                "Info.plist",
            ]
        ),
    ]
)
