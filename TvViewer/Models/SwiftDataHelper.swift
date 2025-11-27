//
//  SwiftDataHelper.swift
//  TvViewer
//
//  Created by Ringo Wathelet on 2025/11/24.
//
import Foundation
import SwiftData
import UIKit


struct SwiftDataHelper {
    
    // change or insert a new station into SwiftData
    // when the station "isFavourite=true" is changed
    static func updateOrInsert(station: TVStation, in context: ModelContext) {
        var descriptor = FetchDescriptor<TVStation>(
            predicate: #Predicate { $0.id == station.id }
        )
        descriptor.fetchLimit = 1
        
        // if already in SwiftData
        if let existing = try? context.fetch(descriptor).first {
            existing.isFavourite = station.isFavourite
        } else {
            // else insert this station in SwiftData
            context.insert(station)
        }
    }
    
    // remove the given station from SwiftData (used when "isFavourite=false")
    static func findAndRemove(station: TVStation, in context: ModelContext) {
        var descriptor = FetchDescriptor<TVStation>(
            predicate: #Predicate { $0.id == station.id }
        )
        descriptor.fetchLimit = 1
        
        // if already in SwiftData
        if let _ = try? context.fetch(descriptor).first {
            context.delete(station)
        }
    }
    
    
    // for testing
    func saveImage(_ image: UIImage, id: String) -> String {
        let filename = "\(id).png"
        let url = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(filename)

        if let data = image.pngData() {
            try? data.write(to: url)
        }
        return filename
    }
    
    // for testing
    func loadImage(filename: String?) -> UIImage? {
        guard let filename else { return nil }
        let url = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(filename)

        return UIImage(contentsOfFile: url.path)
    }

}
