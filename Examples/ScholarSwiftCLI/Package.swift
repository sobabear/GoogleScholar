// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "ScholarSwiftCLI",
    platforms: [
        .macOS(.v10_15)
    ],
    dependencies: [
        .package(path: "../../")
    ],
    targets: [
        .executableTarget(
            name: "ScholarSwiftCLI",
            dependencies: [
                .product(name: "ScholarSwift", package: "ScholarSwift")
            ],
            path: "."
        )
    ]
) 