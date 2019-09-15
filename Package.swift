// swift-tools-version:4.0
//
//  Package.swift
//  MicroExpress
//
//  Created by Helge Hess on 09.03.18.
//  Copyright © 2018 ZeeZide. All rights reserved.
//
import PackageDescription

let package = Package(
    name: "MicroExpress",
    
    products: [
      .library(name: "MicroExpress", targets: ["MicroExpress"]),
    ],
    
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio.git", 
                 from: "2.0.0"),
    ],

    targets: [
        .target(name: "MicroExpress", 
                dependencies: [
                  /* Add your target dependencies in here, e.g.: */
                  // "cows",
                  "NIO",
                  "NIOHTTP1",
                ])
    ]
)
