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
                
                ScrollView {
                    LazyVGrid(
                        columns: [GridItem(.adaptive(minimum: 140), spacing: 16)],
                        spacing: 16
                    ) {
                        ForEach(filteredCountries) { country in
                            NavigationLink {
                                CountryView(country: country, stations: stations)
                            } label: {
                                CountryCard(country: country)
                            }
                        }
                    }
                    .padding()
                }
                .searchable(text: $selector.searchCountry,
                            placement: .navigationBarDrawer,
                            prompt: "Search countries")
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

struct CountryCard: View {
    @Environment(ColorsModel.self) var colorsModel
    let country: TVCountry
    
    var body: some View {
        VStack(spacing: 12) {
            Image(country.code.lowercased())
                .resizable()
                .scaledToFit()
                .frame(height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            Text(country.name)
                .font(.headline)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)

            HStack {
                Image(systemName: "dot.radiowaves.left.and.right")
                Text("\(country.totalStations)").bold()
            }
            .foregroundColor(.primary)
            .font(.subheadline)
            .padding(.vertical, 4)
            .padding(.horizontal, 10)
       //     .glassEffect(.regular, in: .capsule)
            .background(colorsModel.countryBackColor.opacity(0.7))
            .clipShape(Capsule())
        }
        .padding()
        .frame(maxWidth: .infinity)
   //     .glassEffect(.regular, in: .rect(cornerRadius: 22))
        .background(colorsModel.countryBackColor)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.25), radius: 8, y: 4)
    }
}

/*
struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .font(.subheadline)
            
            TextField("Search countries", text: $text)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
        }
        .padding(12)
        .background(.ultraThinMaterial)
        .glassEffect()
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(radius: 4)
    }
}

struct CountriesView2: View {
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
*/
