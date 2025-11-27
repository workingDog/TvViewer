//
//  CountriesView.swift
//  TvViewer
//
//  Created by Ringo Wathelet on 2025/11/24.
//
import SwiftUI


struct CountriesView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(ColorsModel.self) var colorsModel
    @Environment(Selector.self) var selector

    let stations: [TVStation]
    
    @State private var countries: [TVCountry] = []
    
    private var filteredCountries: [TVCountry] {
        let trimmed = selector.searchCountry.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return countries }
        return countries.filter { country in
            let cleanName = country.name.trimmingCharacters(in: .whitespacesAndNewlines)
            return cleanName.lowercased().starts(with: trimmed.lowercased())
        }
    }
    
    var body: some View {
        @Bindable var selector = selector
        NavigationStack {
            ZStack {
                colorsModel.gradient.ignoresSafeArea()
                List(filteredCountries) { country in
                    NavigationLink(destination: CountryView(country: country, stations: stations)) {
                        CountryRow(country: country)
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
                }
                .searchable(text: $selector.searchCountry, placement: .navigationBarDrawer, prompt: "Search countries")
                .scrollContentBackground(.hidden)
                .background(Color.clear)
            }
            .navigationTitle("Countries")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            let kountries: [TVCountry] = stations.compactMap { $0.countryRel }
            // no duplicates and sorted
            countries = Array(Set(kountries)).sorted { $0.name < $1.name }
        }
    }
    
}

struct CountryRow: View {
    @Environment(ColorsModel.self) var colorsModel
    
    let country: TVCountry
    
    var body: some View {
        HStack(spacing: 16) {
            Image(country.code.lowercased())
                .resizable()
                .scaledToFill()
                .frame(width: 50, height: 35)
                .clipShape(RoundedRectangle(cornerRadius: 6))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(country.name)
                    .font(.headline)
                Capsule()
                    .fill(colorsModel.countryBackColor)
                    .overlay {
                        Text("\(country.totalStations)")
                            .bold()
                            .foregroundColor(.primary)
                    }
                    .frame(width: 70, height: 25)
            }
            Spacer()
        }
        .padding()
        .background(colorsModel.countryBackColor)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.6), radius: 4, x: 0, y: 3)
    }
}
