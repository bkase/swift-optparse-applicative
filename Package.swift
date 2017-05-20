// swift-tools-version:3.1

import PackageDescription

let package = Package(
    name: "swift-optparse-applicative",
    targets: [],
    dependencies: [
        .Package(url: "https://github.com/typelift/Operadics.git",
                 majorVersion: 0),
        .Package(url: "https://github.com/typelift/Swiftz.git",
                 majorVersion: 0)
    ]
)
