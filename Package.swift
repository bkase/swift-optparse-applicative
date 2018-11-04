// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "swift-optparse-applicative",
    dependencies: [
        .package(url: "https://github.com/typelift/Operadics.git", from: "0.0.0"),
        .package(url: "https://github.com/typelift/Swiftz.git", from: "0.0.0"),
        .package(url: "https://github.com/bkase/DoctorPretty.git", from: "0.3.0")
    ],
    targets: [
        .target(
            name: "swift-optparse-applicative",
            dependencies: ["Operadics", "Swiftz", "DoctorPretty"]),
        .testTarget(
            name: "swift-optparse-applicativeTests",
            dependencies: ["swift-optparse-applicative"])
    ]
)
