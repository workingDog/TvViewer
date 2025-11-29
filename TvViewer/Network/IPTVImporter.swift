//
//  IPTVImporter.swift
//  TvViewer
//
//  Created by Ringo Wathelet on 2025/11/24.
//
import Foundation
import SwiftData

/*
  temporarily add this to ContentView
 //        .task {
 //            let importer = IPTVImporter(context: modelContext)
 //            do {
 //                try await importer.doImportAll()
 //            } catch {
 //                print(error)
 //            }
 //        }
 
 // also look at TvViewerApp.swift for copying the pre-load db
 
 */

enum APIError: Swift.Error, LocalizedError {
    
    case unknown, apiError(reason: String), parserError(reason: String), networkError(from: URLError)
    
    var errorDescription: String? {
        switch self {
            case .unknown: return "Unknown error"
            case .apiError(let reason), .parserError(let reason): return reason
            case .networkError(let from): return from.localizedDescription
        }
    }
}

// populate the SwiftData database from data fetched from the server.
actor IPTVImporter {

    private let iptvServer = "https://iptv-org.github.io/api"

    let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    // use this to import all the data from the iptvServer
    // and save everything into SwiftData "tvstations.sqlite"
    // takes time to complete
    func doImportAll() async throws {
        do {
            try await importAll()
            print("Imported all IPTV data into SwiftData")
        } catch {
            print("Failed: \(error)")
        }
    }

    private func fetchJSON<T: Decodable>(_ endpoint: String) async throws -> [T] {
        guard let url = URL(string: "\(iptvServer)/\(endpoint).json") else {
            throw URLError(.badURL)
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        try validate(response)
        return try JSONDecoder().decode([T].self, from: data)
    }
    
    func validate(_ response: URLResponse) throws {
        guard let http = response as? HTTPURLResponse else { return }

        switch http.statusCode {
            case 200..<300: return
            case 401: throw APIError.apiError(reason: "Unauthorized")
            case 402: throw APIError.apiError(reason: "Quota exceeded")
            case 403: throw APIError.apiError(reason: "Resource forbidden")
            case 404: throw APIError.apiError(reason: "Resource not found")
            case 429: throw APIError.apiError(reason: "Requesting too quickly")
            case 405..<500: throw APIError.apiError(reason: "Client error")
            case 500..<600: throw APIError.apiError(reason: "Server error")
            default: throw APIError.networkError(from: URLError(.badServerResponse))
        }
    }

    func importAll() async throws {
        
        print("---> importAll start")

        // fetch raw stations (the channels)
        let stations: [TVStation] = try await fetchJSON("channels")
        print("---> stations: \(stations.count)")
        
        // fetch all other data
        let feeds: [TVFeed] = try await fetchJSON("feeds")
        print("---> feeds: \(feeds.count)")
        let logos: [TVLogo] = try await fetchJSON("logos")
        print("---> logos: \(logos.count)")
        let streams: [TVStream] = try await fetchJSON("streams")
        print("---> streams: \(streams.count)")
        let countries: [TVCountry] = try await fetchJSON("countries")
        print("---> countries: \(countries.count)")
        let regions: [TVRegion] = try await fetchJSON("regions")
        print("---> regions: \(regions.count)")
        let timezones: [TVTimezone] = try await fetchJSON("timezones")
        print("---> timezones: \(timezones.count)")

        // not usefull, skip
//        let categories: [TVCategory] = try await fetchJSON("categories")
//        print("---> categories: \(categories.count)")
//        let languages: [TVLanguage] = try await fetchJSON("languages")
//        print("---> languages: \(languages.count)")
        //        let subdivisions: [TVSubdivision] = try await fetchJSON("subdivisions")
        //        print("---> subdivisions: \(subdivisions.count)")
        //        let cities: [TVCity] = try await fetchJSON("cities")
        //        print("---> cities: \(cities.count)")
        //        let guides: [TVGuide] = try await fetchJSON("guides")
        //        print("---> guides: \(guides.count)")
        
        print("\n---> Linking \n")

        // Index stations by ID for linking
        let stationsByID = Dictionary(uniqueKeysWithValues: stations.map { ($0.id, $0) })

        //
        // Link feeds, logos, streams, guides to the corresponding station
        //
        
        for feed in feeds {
            if let station = stationsByID[feed.channel] {
                station.feeds.append(feed)
                feed.station = station
            }
        }
        print("---> Link feeds")
        
        for logo in logos {
            if let station = stationsByID[logo.channel] {
                station.logos.append(logo)
                logo.station = station
            }
        }
        print("---> Link logos")
        
        // only streams with non-nil channel reference
        let filteredStreams = streams.filter({$0.channel != nil})
        print("---> filteredStreams.count: \(filteredStreams.count)")

        for stream in filteredStreams {
            if let channelID = stream.channel, let station = stationsByID[channelID] {
                station.streams.append(stream)
                stream.station = station
            }
        }
        print("---> Link streams")
        
        // only stations with at least one stream, no use otherwise
        let filteredStations = stations.filter({$0.streams.count > 0})
        print("---> filteredStations.count: \(filteredStations.count)")

//        print("---> skip Link guides: \(guides.count)")
//        for guide in guides {
//            if let channelID = guide.channel, let station = stationsByID[channelID] {
//                station.guides.append(guide)
//                guide.station = station
//            }
//        }
//        print("---> Link guides")
        
        // count the number of stations in each country
        for country in countries {
            country.totalStations = filteredStations.filter( { $0.country == country.code }).count
        }

        var progress = 0
        // Link categories, country, regions, timezones
        for station in filteredStations {
            // countryRel
            if let country = countries.first(where: { $0.code == station.country }) {
                station.countryRel = country
            }
            // regions
            station.regions = regions.filter { $0.countries.contains(station.country) }
            // timezones
            station.timezonesRel = timezones.filter { $0.countries.contains(station.country) }
            
            // categoriesRel
            //            station.categoriesRel = categories.filter { station.categories.contains($0.id) }
            // subdivisions
            //            station.subdivisions = subdivisions.filter { $0.country == station.country }
            //            // cities
            //            station.cities = cities.filter { $0.country == station.country }

            if progress.isMultiple(of: 1000) {
                  print("------> progress: \(progress)")
              }
              progress += 1
        }

        print("---> saving to SwiftData")
        
        // Save everything into SwiftData
        for station in filteredStations {
            context.insert(station)
        }
        try context.save()
        
        print("-------> DONE saving all to SwiftData\n")
    }

}
