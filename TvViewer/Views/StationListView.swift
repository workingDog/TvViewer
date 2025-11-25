//
//  StationListView.swift
//  TvViewer
//
//  Created by Ringo Wathelet on 2025/11/24.
//
import SwiftUI


struct StationListView: View {
    @Environment(Selector.self) var selector
    @Environment(PlayerManager.self) var playerManager
    @Environment(ColorsModel.self) var colorsModel
    
    let stations: [TVStation]
    
    let columns: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 4), count: 2)
    
    @State private var searchText = ""
    
    private var filteredStations: [TVStation] {

        let tagStations = stations.filter { station in
            return station.categories.contains(selector.tag.rawValue)
        }

        let zstations = selector.tag == .all ? stations : tagStations

        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return zstations }
        return zstations.filter { station in
            let cleanName = station.name.trimmingCharacters(in: .whitespacesAndNewlines)
            return cleanName.lowercased().starts(with: trimmed.lowercased())
        }
    }

    var body: some View {
        VStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 6) {
                    ForEach(filteredStations) { station in
                        StationView(station: station)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(playerManager.station == station ? colorsModel.borderColor : .clear, lineWidth: 4)
                            )
                            .padding(.horizontal, 4)
                    }
                }
                .contentShape(RoundedRectangle(cornerRadius: 8))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(.horizontal, 6)
            }
            .scrollContentBackground(.hidden)
            .searchable(text: $searchText, prompt: "Search station")
            .textInputAutocapitalization(.never)
            .padding(.horizontal, 6)
        }
    }
    
}

