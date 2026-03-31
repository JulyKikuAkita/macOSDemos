//
//  OnBoardingItem.swift
//  macOSDemos
//

import SwiftUI

struct OnBoardingItem: Identifiable {
    var id: Int
    var title: String
    var subtitle: String
    var screenshot: NSImage?
    var zoomScale: CGFloat = 1
    var zoomAnchor: UnitPoint = .center
}

var sampleOnBoardingMenuItems: [OnBoardingItem] = [
    .init(
        id: 0,
        title: "Welcome to macOS 26",
        subtitle: "Introducing a new design with\nLiquid Glass.",
        screenshot: NSImage(named: "IMG_3003")
    ),
    .init(
        id: 1,
        title: "New Menu Bar",
        subtitle: "Navigate your Mac effortlessly with\na sleel, adaptive menu bar.",
        screenshot: NSImage(named: "fox"),
        zoomScale: 1.8,
        zoomAnchor: .init(x: 1, y: -0.1)
    ),
    .init(
        id: 2,
        title: "Personalized Home Screen",
        subtitle: "Personalized your Mac by\nadding widgets.",
        screenshot: NSImage(named: "fox"),
        zoomScale: 1.8,
        zoomAnchor: .init(x: 0, y: -0.1)
    ),
    .init(
        id: 3,
        title: "All New Spotlight Search",
        subtitle: "Customized your Mac by\nadding widgets.",
        screenshot: NSImage(named: "fox"),
        zoomScale: 1.8,
        zoomAnchor: .init(x: 0.5, y: 1.1)
    ),
    .init(
        id: 2,
        title: "Customized Menu Bar Controls",
        subtitle: "Arrange and tweak controls\nfor a menu bar that adapts to you.",
        screenshot: NSImage(named: "fox"),
        zoomScale: 1.8,
        zoomAnchor: .init(x: 0.5, y: 0.5)
    ),
]
