// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "LifeBar",
    platforms: [.macOS(.v14)],
    targets: [
        .target(name: "LifeBarCore"),
        .executableTarget(
            name: "LifeBar",
            dependencies: ["LifeBarCore"],
            resources: [.copy("Resources/sprites")]
        ),
        .testTarget(name: "LifeBarCoreTests", dependencies: ["LifeBarCore"]),
    ]
)
