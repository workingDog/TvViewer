//
//  SearchStationView.swift
//  TvViewer
//
//  Created by Ringo Wathelet on 2025/11/24.
//
import SwiftUI


struct SearchStationView: View {
    @Environment(Selector.self) var selector
    @Environment(ColorsModel.self) var colorsModel
    
    let stations: [TVStation]
    
    private var filteredStations: [TVStation] {
        let trimmed = selector.searchStation.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }
        return stations.filter { station in
            let cleanName = station.name.trimmingCharacters(in: .whitespacesAndNewlines)
            return cleanName.lowercased().starts(with: trimmed.lowercased())
        }
    }
    
    @State private var isSearching = false
    
    @FocusState private var focused: Bool
    
    var body: some View {
        @Bindable var selector = selector
        ZStack {
            colorsModel.gradient.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    CapsuleSearchField(text: $selector.searchStation, focused: $focused)
                    Spacer()
                }
                .padding(15)

                if isSearching {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                }

                StationListView(stations: filteredStations)
                    .onTapGesture {
                        focused = false
                    }
                
                Spacer()
            }
        }
    }
    
}

struct CapsuleSearchField: View {
    @Binding var text: String
    @FocusState.Binding var focused: Bool

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 21))
                .foregroundStyle(.secondary)

            TextField("Search for stations", text: $text)
                .focused($focused)
                .font(.system(size: 22))
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .background(.clear)

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(10)
        .background( Capsule().fill(.thinMaterial) )
    }
}

