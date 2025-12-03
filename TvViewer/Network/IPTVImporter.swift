//
//  IPTVImporter.swift
//  TvViewer
//
//  Created by Ringo Wathelet on 2025/11/24.
//
import Foundation
import SwiftData


// populate the SwiftData database with data fetched from the server.
struct IPTVImporter {
    
    let networker = Networker()
    let context: ModelContext
    
    init(context: ModelContext) {
        self.context = context
    }
    
    func getStations() throws -> [TVStation] {
        try context.fetch(FetchDescriptor<TVStation>())
    }
    
    func getCurrentFavourites() async -> [String] {
        do {
            let stations = try getStations()
            return stations.filter( { $0.isFavourite }).map(\.id)
        } catch {
            print(error)
        }
        return []
    }
    
    func removeDatabase() async {
        let appSupport = try! FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        
        let names = [
            "tvstations.sqlite",
            "tvstations.sqlite-wal",
            "tvstations.sqlite-shm"
        ]
        
        for name in names {
            let dest = appSupport.appendingPathComponent(name)
            do {
                try FileManager.default.removeItem(at: dest)
            } catch {
                print("Error removing \(name): \(error)")
            }
        }

    }
    
    // use this to import all the data from the iptvServer
    // and save everything into SwiftData "tvstations.sqlite"
    // takes time to complete
    func doImportAll(_ progress: ProgressModel) async throws {
        do {
            // remember the current favourites
            let favourites = await getCurrentFavourites()
            
            await removeDatabase()
            
            try await importData(progress)
            
            // return the favourites
            let stations = try getStations()
            for favourite in favourites {
                if let station = stations.first(where: {$0.id == favourite}) {
                    station.isFavourite = true
                }
            }
        } catch {
            print("Failed: \(error)")
        }
    }
    
    func importData(_ progress: ProgressModel) async throws {
        
        print("---> importData start <---")
        await MainActor.run { progress.value = 0.1 }  // just to show something is going on
        
        // fetch raw stations (the channels)
        let stations: [TVStation] = try await networker.fetchJSON("channels")
        print("---> stations: \(stations.count)")
        
        // fetch all other data
        let feeds: [TVFeed] = try await networker.fetchJSON("feeds")
        print("---> feeds: \(feeds.count)")
        let logos: [TVLogo] = try await networker.fetchJSON("logos")
        print("---> logos: \(logos.count)")
        let streams: [TVStream] = try await networker.fetchJSON("streams")
        print("---> streams: \(streams.count)")
        var countries: [TVCountry] = try await networker.fetchJSON("countries")
        print("---> countries: \(countries.count)")
        let regions: [TVRegion] = try await networker.fetchJSON("regions")
        print("---> regions: \(regions.count)")
        let timezones: [TVTimezone] = try await networker.fetchJSON("timezones")
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
        
        await MainActor.run { progress.value = 0.2 } // just to show something is going on
 
        print("\n---> Linking <---\n")
        
        // Index stations by ID for linking
        let stationsByID = Dictionary(uniqueKeysWithValues: stations.map { ($0.id, $0) })
        
        //
        // Link feeds, logos, streams, etc... to the corresponding station
        //
        
        // only streams with non-nil channel reference
        let filteredStreams = streams.filter({$0.channel != nil})
        print("---> filteredStreams.count: \(filteredStreams.count)")
        
        // the total number of progress steps
        let total = feeds.count + logos.count + (2 * filteredStreams.count) + countries.count
        print("---> total: \(total)")
        
        await MainActor.run {
            progress.completed = 0
        }
        
        for feed in feeds {
            if let station = stationsByID[feed.channel] {
                station.feeds.append(feed)
                feed.station = station
            }
            await MainActor.run {
                progress.completed += 1
                progress.value = Double(progress.completed) / Double(total)
            }
        }
        print("---> Link feeds")
        
        for logo in logos {
            if let station = stationsByID[logo.channel] {
                station.logos.append(logo)
                logo.station = station
            }
            await MainActor.run {
                progress.completed += 1
                progress.value = Double(progress.completed) / Double(total)
            }
        }
        print("---> Link logos")
        
        for stream in filteredStreams {
            if let channelID = stream.channel, let station = stationsByID[channelID] {
                station.streams.append(stream)
                stream.station = station
            }
            await MainActor.run {
                progress.completed += 1
                progress.value = Double(progress.completed) / Double(total)
            }
        }
        print("---> Link streams")
        
        // only stations with at least one stream, no use otherwise
        let filteredStations = stations.filter({$0.streams.count > 0})
        print("---> filteredStations.count: \(filteredStations.count)")

        // count the number of stations in each country
        for country in countries {
            country.totalStations = filteredStations.filter( { $0.country == country.code }).count
            await MainActor.run {
                progress.completed += 1
                progress.value = Double(progress.completed) / Double(total)
            }
        }

        print("---> Linking categories, country, regions, timezones")
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
            
            await MainActor.run {
                progress.completed += 1
                progress.value = Double(progress.completed) / Double(total)
            }
        }
        
        print("---> saving to SwiftData")
        
        // insert everything into SwiftData
        for station in filteredStations {
            context.insert(station)
        }
        
        // save
        do {
            try context.save()
        } catch {
            print("----------> Error saving to SwiftData: \(error) <----------")
        }

        await MainActor.run { progress.value = 1.0 }
        print("-------> DONE saving all to SwiftData\n")
    }
    
}
