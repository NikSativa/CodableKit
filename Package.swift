// swift-tools-version:6.0
// swiftformat:disable all
import PackageDescription

let package = Package(
    name: "CodableKit",
    platforms: [
        .iOS(.v15),
        .macOS(.v14),
        .macCatalyst(.v15),
        .visionOS(.v1),
        .tvOS(.v16),
        .watchOS(.v9)
    ],
    products: [
        .library(name: "CodableKit", targets: ["CodableKit"])
    ],
    dependencies: [
    ],
    targets: [
        .target(name: "CodableKit",
                dependencies: [
                ],
                path: "Source",
                resources: [
                    .process("PrivacyInfo.xcprivacy")
                ]),
        .testTarget(name: "CodableKitTests",
                    dependencies: [
                        "CodableKit"
                    ],
                    path: "Tests")
    ]
)
