//
//  TvViewerApp.swift
//  TvViewer
//
//  Created by Ringo Wathelet on 2025/11/23.
//

import SwiftUI
import SwiftData

/*
 
 https://github.com/iptv-org/api
 
 https://github.com/iptv-org/database
 
 https://iptv-org.github.io/api/streams.json
 
 raw data of channel info and stream url in M3U format
 https://iptv-org.github.io/iptv/index.m3u
 
 */

@main
struct TvViewerApp: App {
    @State private var colorsModel = ColorsModel()
    
    var sharedModelContainer: ModelContainer = {
        let appSupportDir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).last

        // find or install our preloaded DB
        let dbURL = TvViewerApp.preloadDBIfNeeded()
        print("-----> database dbURL: \(dbURL)")

        let schema = Schema([
            TVStation.self, TVFeed.self, TVLogo.self, TVStream.self, TVGuide.self,
            TVCategory.self, TVLanguage.self, TVCountry.self, TVSubdivision.self,
            TVCity.self, TVRegion.self, TVTimezone.self
        ])
        let config = ModelConfiguration(schema: schema, url: dbURL)
        do {
            return try ModelContainer(for: schema, configurations: config)
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(colorsModel)
        }
        .modelContainer(sharedModelContainer)
    }
    
    static func preloadDBIfNeeded() -> URL {
        let fm = FileManager.default
        
        let appSupport = try! fm.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )

        let sqlite = appSupport.appendingPathComponent("tvstations.sqlite")

        if !fm.fileExists(atPath: sqlite.path) {
            // copy the db files from bundle to appSupport
            TvViewerApp.copyFilesTo(appSupport)
        }

        return sqlite
    }
    
    static func copyFilesTo(_ appSupport: URL) {
        
        // Copy all three required files
        let names = [
            "tvstations.sqlite",
            "tvstations.sqlite-wal",
            "tvstations.sqlite-shm"
        ]

        for name in names {
            if let source = Bundle.main.url(forResource: name, withExtension: nil) {
                let dest = appSupport.appendingPathComponent(name)
                do {
                    try FileManager.default.copyItem(at: source, to: dest)
                    print("---> Copied \(name)")
                } catch {
                    print("Error copying \(name): \(error)")
                }
            } else {
                print("⚠️ Missing \(name) in app bundle!")
            }
        }
    }

}
