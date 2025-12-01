//
//  Networker.swift
//  TvViewer
//
//  Created by Ringo Wathelet on 2025/11/30.
//
import Foundation
import SwiftData
import UIKit


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

// fetch data from the server.
struct Networker {
    
    private let iptvServer = "https://iptv-org.github.io/api"
    
    init() { }
    
    func fetchJSON<T: Decodable>(_ endpoint: String) async throws -> T {
        guard let url = URL(string: "\(iptvServer)/\(endpoint).json") else {
            throw URLError(.badURL)
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        try validate(response)
        return try JSONDecoder().decode(T.self, from: data)
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
    
    static func defaultTvLogo() -> UIImage {
        UIImage(named: "teve")!
    }
    
    func fetchLogo(for tvlogo: TVLogo) async {
        if tvlogo.url == "null" || tvlogo.url.isEmpty { return }
        guard let logoURL = URL(string: tvlogo.url) else { return }
        do {
            let (data, response) = try await URLSession.shared.data(from: logoURL)
            try validate(response)
            tvlogo.logoData = data
        }
        catch {
            //  print(error)
        }
    }
    
    func logoImage(for tvlogo: TVLogo) async -> UIImage {
        // If no data cached, fetch it
        if tvlogo.logoData == nil {
            await fetchLogo(for: tvlogo)
            if let data = tvlogo.logoData, let img = UIImage(data: data) {
                return img
            } else {
                let fallback = Networker.defaultTvLogo()
                tvlogo.logoData = fallback.pngData()
                return fallback
            }
        }
        // If data exists, try to decode it
        if let data = tvlogo.logoData, let img = UIImage(data: data) {
            return img
        } else {
            let fallback = Networker.defaultTvLogo()
            tvlogo.logoData = fallback.pngData()
            return fallback
        }
    }
    
    func tvLogoImage(for tvStation: TVStation) async -> UIImage {
        if let firstLogo = tvStation.logos.first {
            return await logoImage(for: firstLogo)
        } else {
            return Networker.defaultTvLogo()
        }
    }
    
}
