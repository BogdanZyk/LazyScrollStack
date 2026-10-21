//
//  CellModel.swift
//  LazyScrollStack
//

import Foundation

@MainActor
struct CellModel: Identifiable {
    private static let icons = [
        "book.closed.fill", "camera.fill", "headphones",
        "map.fill", "paintpalette.fill", "gamecontroller.fill",
        "cup.and.saucer.fill", "backpack.fill"
    ]
    
    private static let titles = [
        "Reading list",
        "Photo walk",
        "Morning playlist",
        "Weekend route",
        "Sketch ideas",
        "Game night"
    ]

    private static let subtitles = [
        "Saved for later",
        "Ready to explore",
        "Updated today",
        "A quick demo row",
        "Part of the sample data"
    ]
    
    let index: Int
    let title: String
    let subtitle: String
    let icon: String
    var isOn: Bool

    var id: Int { index }
    
    init(index: Int) {
        self.index = index
        self.title = "\(index + 1). \(Self.titles[index % Self.titles.count])"
        self.subtitle = Self.subtitles[index % Self.subtitles.count]
        self.icon = Self.icons[index % Self.icons.count]
        self.isOn = false
    }
}
