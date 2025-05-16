// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "GoogleScholar",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "GoogleScholar",
            targets: ["GoogleScholar"]),
    ],
    dependencies: [
        .package(url: "https://github.com/scinfu/SwiftSoup.git", from: "2.6.0"),
    ],
    targets: [
        .target(
            name: "GoogleScholar",
            dependencies: ["SwiftSoup"]),
        .testTarget(
            name: "GoogleScholarTests",
            dependencies: ["GoogleScholar"]),
    ]
) 
