//
//  IptvModels.swift
//  TvViewer
//
//  Created by Ringo Wathelet on 2025/11/24.
//
import Foundation
import SwiftData
import UIKit


// helper actor to fetch logo icon
actor LogoService {
    static let shared = LogoService()
    
    static func defaultTvLogo() -> UIImage {
        UIImage(named: "teve")!
    }
    
    private func fetchLogo(for tvlogo: TVLogo) async {
        if tvlogo.url == "null" || tvlogo.url.isEmpty { return }
        guard let logoURL = URL(string: tvlogo.url) else { return }
        do {
            let (data, _) = try await URLSession.shared.data(from: logoURL)
            tvlogo.logoData = data
        } catch {
            print(error)
        }
    }
    
    func logoImage(for tvlogo: TVLogo) async -> UIImage {
        // If no data cached, fetch it
        if tvlogo.logoData == nil {
            await fetchLogo(for: tvlogo)
            if let data = tvlogo.logoData, let img = UIImage(data: data) {
                return img
            } else {
                let fallback = LogoService.defaultTvLogo()
                tvlogo.logoData = fallback.pngData()
                return fallback
            }
        }
        // If data exists, try to decode it
        if let data = tvlogo.logoData, let img = UIImage(data: data) {
            return img
        } else {
            let fallback = LogoService.defaultTvLogo()
            tvlogo.logoData = fallback.pngData()
            return fallback
        }
    }
    
    func tvLogoImage(for tvStation: TVStation) async -> UIImage {
        if let firstLogo = tvStation.logos.first {
            return await logoImage(for: firstLogo)
        } else {
            return LogoService.defaultTvLogo()
        }
    }
    
}

@Model
final class TVStation: Codable {
    @Attribute(.unique) var id: String
    
    // stored, but not encoded or decoded
    var isFavourite: Bool = false
    
    var name: String
    var alt_names: [String]
    var network: String?
    var owners: [String]
    var country: String   // <-- this is country code
    var categories: [String]
    var is_nsfw: Bool
    var launched: String?
    var closed: String?
    var replaced_by: String?
    var website: String?

    // Relationships
    @Relationship(deleteRule: .cascade) var feeds: [TVFeed] = []
    @Relationship(deleteRule: .cascade) var logos: [TVLogo] = []
    @Relationship(deleteRule: .cascade) var streams: [TVStream] = []
    @Relationship(deleteRule: .cascade) var guides: [TVGuide] = []
    
    @Relationship(deleteRule: .cascade) var categoriesRel: [TVCategory] = []
    @Relationship(deleteRule: .cascade) var languagesRel: [TVLanguage] = []
    @Relationship(deleteRule: .cascade) var countryRel: TVCountry?
    @Relationship(deleteRule: .cascade) var subdivisions: [TVSubdivision] = []
    @Relationship(deleteRule: .cascade) var cities: [TVCity] = []
    @Relationship(deleteRule: .cascade) var regions: [TVRegion] = []
    @Relationship(deleteRule: .cascade) var timezonesRel: [TVTimezone] = []

    init(id: String,
         name: String,
         alt_names: [String] = [],
         network: String? = nil,
         owners: [String] = [],
         country: String,
         categories: [String] = [],
         is_nsfw: Bool = false,
         launched: String? = nil,
         closed: String? = nil,
         replaced_by: String? = nil,
         website: String? = nil)
    {
        self.id = id
        self.name = name
        self.alt_names = alt_names
        self.network = network
        self.owners = owners
        self.country = country
        self.categories = categories
        self.is_nsfw = is_nsfw
        self.launched = launched
        self.closed = closed
        self.replaced_by = replaced_by
        self.website = website
    }

    enum CodingKeys: String, CodingKey {
        case id, name
        case alt_names
        case network, owners, country, categories
        case is_nsfw
        case launched, closed
        case replaced_by
        case website
    }

    convenience init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            id: try c.decode(String.self, forKey: .id),
            name: try c.decode(String.self, forKey: .name),
            alt_names: try c.decodeIfPresent([String].self, forKey: .alt_names) ?? [],
            network: try c.decodeIfPresent(String.self, forKey: .network),
            owners: try c.decodeIfPresent([String].self, forKey: .owners) ?? [],
            country: try c.decode(String.self, forKey: .country),
            categories: try c.decodeIfPresent([String].self, forKey: .categories) ?? [],
            is_nsfw: try c.decodeIfPresent(Bool.self, forKey: .is_nsfw) ?? false,
            launched: try c.decodeIfPresent(String.self, forKey: .launched),
            closed: try c.decodeIfPresent(String.self, forKey: .closed),
            replaced_by: try c.decodeIfPresent(String.self, forKey: .replaced_by),
            website: try c.decodeIfPresent(String.self, forKey: .website)
        )
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(name, forKey: .name)
        try c.encode(alt_names, forKey: .alt_names)
        try c.encodeIfPresent(network, forKey: .network)
        try c.encode(owners, forKey: .owners)
        try c.encode(country, forKey: .country)
        try c.encode(categories, forKey: .categories)
        try c.encode(is_nsfw, forKey: .is_nsfw)
        try c.encodeIfPresent(launched, forKey: .launched)
        try c.encodeIfPresent(closed, forKey: .closed)
        try c.encodeIfPresent(replaced_by, forKey: .replaced_by)
        try c.encodeIfPresent(website, forKey: .website)
    }
    
}

@Model
final class TVFeed: Codable {
    var channel: String
    @Attribute(.unique) var id: String
    var name: String
    var alt_names: [String]
    var is_main: Bool
    var broadcast_area: [String]
    var timezones: [String]
    var languages: [String]
    var format: String

    var station: TVStation?

    init(channel: String,
         id: String,
         name: String,
         alt_names: [String] = [],
         is_main: Bool = false,
         broadcast_area: [String] = [],
         timezones: [String] = [],
         languages: [String] = [],
         format: String,
         station: TVStation? = nil)
    {
        self.channel = channel
        self.id = id
        self.name = name
        self.alt_names = alt_names
        self.is_main = is_main
        self.broadcast_area = broadcast_area
        self.timezones = timezones
        self.languages = languages
        self.format = format
        self.station = station
    }

    enum CodingKeys: String, CodingKey {
        case channel, id, name
        case alt_names, is_main, broadcast_area, timezones, languages, format
    }

    convenience init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            channel: try c.decode(String.self, forKey: .channel),
            id: try c.decode(String.self, forKey: .id),
            name: try c.decode(String.self, forKey: .name),
            alt_names: try c.decodeIfPresent([String].self, forKey: .alt_names) ?? [],
            is_main: try c.decodeIfPresent(Bool.self, forKey: .is_main) ?? false,
            broadcast_area: try c.decodeIfPresent([String].self, forKey: .broadcast_area) ?? [],
            timezones: try c.decodeIfPresent([String].self, forKey: .timezones) ?? [],
            languages: try c.decodeIfPresent([String].self, forKey: .languages) ?? [],
            format: try c.decode(String.self, forKey: .format)
        )
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(channel, forKey: .channel)
        try c.encode(id, forKey: .id)
        try c.encode(name, forKey: .name)
        try c.encode(alt_names, forKey: .alt_names)
        try c.encode(is_main, forKey: .is_main)
        try c.encode(broadcast_area, forKey: .broadcast_area)
        try c.encode(timezones, forKey: .timezones)
        try c.encode(languages, forKey: .languages)
        try c.encode(format, forKey: .format)
    }
}

@Model
final class TVLogo: Codable {
    // not stored, not decoded
    @Transient var logoData: Data? = nil
    
    var channel: String
    var feed: String?
    var tags: [String]
    var width: Double?
    var height: Double?
    var format: String?
    var url: String

    var station: TVStation?

    init(channel: String,
         feed: String? = nil,
         tags: [String] = [],
         width: Double?,
         height: Double?,
         format: String? = nil,
         url: String,
         station: TVStation? = nil)
    {
        self.channel = channel
        self.feed = feed
        self.tags = tags
        self.width = width
        self.height = height
        self.format = format
        self.url = url
        self.station = station
    }

    enum CodingKeys: String, CodingKey {
        case channel, feed, tags, width, height, format, url
    }

    convenience init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            channel: try c.decode(String.self, forKey: .channel),
            feed: try c.decodeIfPresent(String.self, forKey: .feed),
            tags: try c.decodeIfPresent([String].self, forKey: .tags) ?? [],
            width: try c.decodeIfPresent(Double.self, forKey: .width),
            height: try c.decodeIfPresent(Double.self, forKey: .height),
            format: try c.decodeIfPresent(String.self, forKey: .format),
            url: try c.decode(String.self, forKey: .url)
        )
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(channel, forKey: .channel)
        try c.encodeIfPresent(feed, forKey: .feed)
        try c.encode(tags, forKey: .tags)
        try c.encodeIfPresent(width, forKey: .width)
        try c.encodeIfPresent(height, forKey: .height)
        try c.encodeIfPresent(format, forKey: .format)
        try c.encode(url, forKey: .url)
    }
 
}

@Model
final class TVStream: Codable {
    var channel: String?
    var feed: String?
    var title: String
    var url: String
    var referrer: String?
    var user_agent: String?
    var quality: String?

    var station: TVStation?

    init(channel: String? = nil,
         feed: String? = nil,
         title: String,
         url: String,
         referrer: String? = nil,
         user_agent: String? = nil,
         quality: String? = nil,
         station: TVStation? = nil)
    {
        self.channel = channel
        self.feed = feed
        self.title = title
        self.url = url
        self.referrer = referrer
        self.user_agent = user_agent
        self.quality = quality
        self.station = station
    }

    enum CodingKeys: String, CodingKey {
        case channel, feed, title, url, referrer
        case user_agent, quality
    }

    convenience init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            channel: try c.decodeIfPresent(String.self, forKey: .channel),
            feed: try c.decodeIfPresent(String.self, forKey: .feed),
            title: try c.decode(String.self, forKey: .title),
            url: try c.decode(String.self, forKey: .url),
            referrer: try c.decodeIfPresent(String.self, forKey: .referrer),
            user_agent: try c.decodeIfPresent(String.self, forKey: .user_agent),
            quality: try c.decodeIfPresent(String.self, forKey: .quality)
        )
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encodeIfPresent(channel, forKey: .channel)
        try c.encodeIfPresent(feed, forKey: .feed)
        try c.encode(title, forKey: .title)
        try c.encode(url, forKey: .url)
        try c.encodeIfPresent(referrer, forKey: .referrer)
        try c.encodeIfPresent(user_agent, forKey: .user_agent)
        try c.encodeIfPresent(quality, forKey: .quality)
    }
}

@Model
final class TVGuide: Codable {
    var channel: String?
    var feed: String?
    var site: String?
    var site_id: String?
    var site_name: String?
    var lang: String?

    var station: TVStation?

    init(channel: String? = nil,
         feed: String? = nil,
         site: String?,
         site_id: String?,
         site_name: String?,
         lang: String?,
         station: TVStation? = nil)
    {
        self.channel = channel
        self.feed = feed
        self.site = site
        self.site_id = site_id
        self.site_name = site_name
        self.lang = lang
        self.station = station
    }

    enum CodingKeys: String, CodingKey {
        case channel, feed, site, site_id, site_name, lang
    }

    convenience init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            channel: try c.decodeIfPresent(String.self, forKey: .channel),
            feed: try c.decodeIfPresent(String.self, forKey: .feed),
            site: try c.decodeIfPresent(String.self, forKey: .site),
            site_id: try c.decodeIfPresent(String.self, forKey: .site_id),
            site_name: try c.decodeIfPresent(String.self, forKey: .site_name),
            lang: try c.decodeIfPresent(String.self, forKey: .lang)
        )
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encodeIfPresent(channel, forKey: .channel)
        try c.encodeIfPresent(feed, forKey: .feed)
        try c.encodeIfPresent(site, forKey: .site)
        try c.encodeIfPresent(site_id, forKey: .site_id)
        try c.encodeIfPresent(site_name, forKey: .site_name)
        try c.encodeIfPresent(lang, forKey: .lang)
    }
}

@Model
final class TVCategory: Codable {
    @Attribute(.unique) var id: String
    var name: String
    var info: String

    var station: TVStation?

    init(id: String,
         name: String,
         info: String,
         station: TVStation? = nil)
    {
        self.id = id
        self.name = name
        self.info = info
        self.station = station
    }

    enum CodingKeys: String, CodingKey {
        case id, name
        case info = "description"
    }

    convenience init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            id: try c.decode(String.self, forKey: .id),
            name: try c.decode(String.self, forKey: .name),
            info: try c.decode(String.self, forKey: .info)
        )
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(name, forKey: .name)
        try c.encode(info, forKey: .info)
    }
}

@Model
final class TVLanguage: Codable {
    var name: String
    @Attribute(.unique) var code: String

    var station: TVStation?

    init(name: String,
         code: String,
         station: TVStation? = nil)
    {
        self.name = name
        self.code = code
        self.station = station
    }

    enum CodingKeys: String, CodingKey {
        case name, code
    }

    convenience init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            name: try c.decode(String.self, forKey: .name),
            code: try c.decode(String.self, forKey: .code)
        )
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(name, forKey: .name)
        try c.encode(code, forKey: .code)
    }
}

@Model
final class TVCountry: Codable {
    var name: String
    @Attribute(.unique) var code: String
    var languages: [String]
    var flag: String
    
    var totalStations: Int = 0  // to be set during import

    var station: TVStation?
    
    init(name: String,
         code: String,
         languages: [String] = [],
         flag: String,
         station: TVStation? = nil)
    {
        self.name = name
        self.code = code
        self.languages = languages
        self.flag = flag
        self.station = station
    }

    enum CodingKeys: String, CodingKey {
        case name, code, languages, flag
    }

    convenience init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            name: try c.decode(String.self, forKey: .name),
            code: try c.decode(String.self, forKey: .code),
            languages: try c.decodeIfPresent([String].self, forKey: .languages) ?? [],
            flag: try c.decode(String.self, forKey: .flag)
        )
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(name, forKey: .name)
        try c.encode(code, forKey: .code)
        try c.encode(languages, forKey: .languages)
        try c.encode(flag, forKey: .flag)
    }

}

@Model
final class TVSubdivision: Codable {
    var country: String
    var name: String
    @Attribute(.unique) var code: String
    var parent: String?

    var station: TVStation?

    init(country: String,
         name: String,
         code: String,
         parent: String? = nil,
         station: TVStation? = nil)
    {
        self.country = country
        self.name = name
        self.code = code
        self.parent = parent
        self.station = station
    }

    enum CodingKeys: String, CodingKey {
        case country, name, code, parent
    }

    convenience init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            country: try c.decode(String.self, forKey: .country),
            name: try c.decode(String.self, forKey: .name),
            code: try c.decode(String.self, forKey: .code),
            parent: try c.decodeIfPresent(String.self, forKey: .parent)
        )
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(country, forKey: .country)
        try c.encode(name, forKey: .name)
        try c.encode(code, forKey: .code)
        try c.encodeIfPresent(parent, forKey: .parent)
    }
}

@Model
final class TVCity: Codable {
    var country: String
    var subdivision: String?
    var name: String
    @Attribute(.unique) var code: String
    var wikidata_id: String

    var station: TVStation?

    init(country: String,
         subdivision: String? = nil,
         name: String,
         code: String,
         wikidata_id: String,
         station: TVStation? = nil)
    {
        self.country = country
        self.subdivision = subdivision
        self.name = name
        self.code = code
        self.wikidata_id = wikidata_id
        self.station = station
    }

    enum CodingKeys: String, CodingKey {
        case country, subdivision, name, code, wikidata_id
    }

    convenience init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            country: try c.decode(String.self, forKey: .country),
            subdivision: try c.decodeIfPresent(String.self, forKey: .subdivision),
            name: try c.decode(String.self, forKey: .name),
            code: try c.decode(String.self, forKey: .code),
            wikidata_id: try c.decode(String.self, forKey: .wikidata_id)
        )
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(country, forKey: .country)
        try c.encodeIfPresent(subdivision, forKey: .subdivision)
        try c.encode(name, forKey: .name)
        try c.encode(code, forKey: .code)
        try c.encode(wikidata_id, forKey: .wikidata_id)
    }
}

@Model
final class TVRegion: Codable {
    @Attribute(.unique) var code: String
    var name: String
    var countries: [String]

    var station: TVStation?

    init(code: String,
         name: String,
         countries: [String] = [],
         station: TVStation? = nil)
    {
        self.code = code
        self.name = name
        self.countries = countries
        self.station = station
    }

    enum CodingKeys: String, CodingKey {
        case code, name, countries
    }

    convenience init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            code: try c.decode(String.self, forKey: .code),
            name: try c.decode(String.self, forKey: .name),
            countries: try c.decodeIfPresent([String].self, forKey: .countries) ?? []
        )
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(code, forKey: .code)
        try c.encode(name, forKey: .name)
        try c.encode(countries, forKey: .countries)
    }
}

@Model
final class TVTimezone: Codable {
    @Attribute(.unique) var id: String
    var utc_offset: String
    var countries: [String]

    var station: TVStation?

    init(id: String,
         utc_offset: String,
         countries: [String] = [],
         station: TVStation? = nil)
    {
        self.id = id
        self.utc_offset = utc_offset
        self.countries = countries
        self.station = station
    }

    enum CodingKeys: String, CodingKey {
        case id, utc_offset, countries
    }

    convenience init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            id: try c.decode(String.self, forKey: .id),
            utc_offset: try c.decode(String.self, forKey: .utc_offset),
            countries: try c.decode([String].self, forKey: .countries)
        )
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(utc_offset, forKey: .utc_offset)
        try c.encode(countries, forKey: .countries)
    }
}
