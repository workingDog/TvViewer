//
//  ContentView.swift
//  TvViewer
//
//  Created by Ringo Wathelet on 2025/11/23.
//

import SwiftUI
import SwiftData
import Foundation
import UIKit
import AVKit
import AVFoundation


struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(ColorsModel.self) var colorsModel
    
    @State private var playerManager = PlayerManager()
    @State private var selector = Selector()

    @Query private var stations: [TVStation]

    var body: some View {
        ZStack(alignment: .top) {
            AppBackground().ignoresSafeArea()
                .animation(.easeInOut(duration: 0.4), value: selector.view)
            
            if playerManager.showVideo {
                VideoView()
            } else {
                VStack {
                    ToolsView()
                    
                    if selector.view != .countries {
                        FilterToolsView().fixedSize()
                    }
                    
                    switch selector.view {
                        case .favourites: StationListView(stations: stations.filter({$0.isFavourite}))
                            
                        case .countries: CountriesView(stations: stations)
                            
                        case .stations: SearchStationView(stations: stations)
                    }
                }
            }
        }
        .onAppear {
            selector.retrieveSettings()
            colorsModel.retrieveSettings()
            print("\n----> stations: \(stations.count)\n")
            
            
//            for station in stations.prefix(20) {
//                if let stream = station.streams.first?.url, let url = URL(string: stream) {
//                    print("---> \(station.name) \n \(stream) \n")
//                }
//            }
            
            /*
             ABC News
              https://c.mjh.nz/abc-news.m3u8
             */
            
        }
        .environment(playerManager)
        .environment(selector)
    }
}
