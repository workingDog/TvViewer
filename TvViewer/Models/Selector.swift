//
//  Selector.swift
//  TvViewer
//
//  Created by Ringo Wathelet on 2025/11/24.
//
import Foundation
import SwiftUI


@MainActor
@Observable
class Selector {
    
    var view: ViewTypes = .favourites
    var tag: StationTag = .all
    var searchStation: String = ""
    var pingSound: Bool = true
    
    static let keyTag: String = "tag"
    static let keyPingSound: String = "pingSound"
    
    
    func storeSettings() {
        UserDefaults.standard.set(self.tag.rawValue, forKey: Selector.keyTag)
        UserDefaults.standard.set(self.pingSound, forKey: Selector.keyPingSound)
    }
    
    func retrieveSettings() {
        let xtag = UserDefaults.standard.string(forKey: Selector.keyTag) ?? StationTag.all.rawValue
        self.tag = StationTag(rawValue: xtag) ?? .all
        
        self.pingSound = UserDefaults.standard.bool(forKey: Selector.keyPingSound)
    }
    
}

enum ViewTypes: String, CaseIterable, Identifiable {
    case favourites = "Favourites"
    case countries = "Countries"
    case stations = "Stations"
    
    var id: String { rawValue }
}

enum StationTag: String, CaseIterable, Codable, Identifiable {
    case all
    case animation
    case auto
    case business
    case classic
    case comedy
    case cooking
    case culture
    case documentary
    case education
    case entertainment
    case family
    case general
    case kids
    case legislative
    case lifestyle
    case movies
    case music
    case news
    case outdoor
    case relax
    case religious
    case science
    case series
    case shop
    case sports
    case travel
    case weather

    var id: String { rawValue }
    
    var displayName: String {
        rawValue.capitalized
    }
}

