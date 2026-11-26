// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PTModeCore",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "PTModeCore", targets: ["PTModeCore"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "PTModeCore",
            dependencies: [],
            path: "Sources/PTModeCore",
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "PTModeCoreTests",
            dependencies: ["PTModeCore"],
            path: "Tests/PTModeCoreTests"
        )
    ]
)
