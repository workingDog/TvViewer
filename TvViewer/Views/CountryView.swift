//
//  CountryView.swift
//  TvViewer
//
//  Created by Ringo Wathelet on 2025/11/24.
//
import SwiftUI
import SwiftData


struct CountryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(Selector.self) var selector
    @Environment(ColorsModel.self) var colorsModel
    
    let country: TVCountry
    let stations: [TVStation]
    
    var filteredStations: [TVStation] {
         stations.filter { $0.country == country.code }
    }
    
    var body: some View {
        ZStack {
            colorsModel.gradient.ignoresSafeArea()
            VStack {
                if filteredStations.isEmpty {
                    ProgressView()
                } else {
                    FilterToolsView().fixedSize()
                    StationListView(stations: filteredStations)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack(spacing: 8) {
                    Image(country.code.lowercased())
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 20)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                    Text(country.name)
                        .font(.headline)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
    
}
