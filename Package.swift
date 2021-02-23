// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift_ai",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        /*.executable(
            name: "GraphicalControlApp",
            targets: ["GraphicalControlApp"]),*/
        .executable(name: "ShapePolicyEvolver", targets: ["ShapePolicyEvolver"]),
        .executable(name: "2DSimulation", targets: ["2DSimulation"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(name: "SwiftGUI", path: "../swift-gui"),
        .package(name: "GfxMath", path: "../swift-gfx-math")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(name: "Evolution"),
        .target(
            name: "GraphicalControlApp",
            dependencies: ["SwiftGUI"]),
        .target(name: "2DSimulation", dependencies: ["SwiftGUI", "GraphicalControlApp", "Evolution"]),
        .target(name: "ShapePolicyEvolver", dependencies: ["SwiftGUI", "GraphicalControlApp", "Evolution"]),
        .testTarget(
            name: "swift_aiTests",
            dependencies: []),
    ]
)
