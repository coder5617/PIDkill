// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PIDkill",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "PIDkill", targets: ["PIDkill"])
    ],
    targets: [
        .executableTarget(
            name: "PIDkill",
            path: ".",
            exclude: ["PIDkill.md", "README.md", ".gitignore", "Resources/Info.plist", "Resources/AppIcon.icns", "Tests", "scripts", "PIDkill.app"],
            sources: [
                "App",
                "Models",
                "Services",
                "ViewModels",
                "Views"
            ]
        ),
        .testTarget(
            name: "PIDkillTests",
            dependencies: ["PIDkill"],
            path: "Tests"
        )
    ]
)
