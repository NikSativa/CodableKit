// swift-tools-version:5.8
// swiftformat:disable all
import PackageDescription

let package = Package(
    name: "CodableKit",
    platforms: [
        .iOS(.v13),
        .macOS(.v11),
        .macCatalyst(.v13),
        .tvOS(.v13),
        .watchOS(.v6)
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
