//
//  AppLogger.swift
//  TvViewer
//
//  Created by Ringo Wathelet on 2026/01/07.
//

import OSLog

enum AppLogger {
    
    static let subsystem = Bundle.main.bundleIdentifier!
    static let app = Logger(subsystem: subsystem, category: "app")
    
    static func logPrivate(_ error: Error) {
        app.error("\(error, privacy: .private)")
        #if DEBUG
        print("❌ \(error)")
        #endif
    }
    
    static func logPublic(_ error: Error) {
        logPublic("", error)
    }
    
    static func logPublic(_ message: String, _ error: Error) {
        app.error("\(message, privacy: .public) — \(error, privacy: .public)")
        #if DEBUG
        print("❌ \(message): \(error)")
        #endif
    }

}
