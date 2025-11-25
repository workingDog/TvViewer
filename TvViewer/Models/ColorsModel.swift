//
//  ColorsModel.swift
//  TvViewer
//
//  Created by Ringo Wathelet on 2025/11/23.
//
import Foundation
import SwiftUI


@MainActor
@Observable
class ColorsModel {
    
    var favouriteColor = Color.teal
    var netColor = Color.blue
    var borderColor = Color.accentColor
    var backColor = Color.mint.opacity(0.4)
    var stationBackColor = Color.white.opacity(0.4)
    var countryBackColor = Color.teal.opacity(0.4)
    
    // keys for UserDefaults
    static let keyFavouriteColor: String = "favouriteColor"
    static let keyNetColor: String = "netColor"
    static let keyBorderColor: String = "borderColor"
    static let keyBackColor: String = "backColor"
    static let keyStationBackColor: String = "stationBackColor"
    static let keyCountryBackColor: String = "countryBackColor"
    
    // convenience color gradient
    var gradient: LinearGradient {
        LinearGradient(gradient: Gradient(colors: [backColor.opacity(1), backColor.opacity(0.3)]), startPoint: .top, endPoint: .bottom)
    }
    
    // store settings in UserDefaults
    func storeSettings() {
        UserDefaults.standard.set(self.favouriteColor.toHex(), forKey: ColorsModel.keyFavouriteColor)
        UserDefaults.standard.set(self.netColor.toHex(), forKey: ColorsModel.keyNetColor)
        UserDefaults.standard.set(self.borderColor.toHex(), forKey: ColorsModel.keyBorderColor)
        UserDefaults.standard.set(self.backColor.toHex(), forKey: ColorsModel.keyBackColor)
        UserDefaults.standard.set(self.stationBackColor.toHex(), forKey: ColorsModel.keyStationBackColor)
        UserDefaults.standard.set(self.countryBackColor.toHex(), forKey: ColorsModel.keyCountryBackColor)
    }
    
    // retrieve settings from UserDefaults
    func retrieveSettings() {
        let fav = UserDefaults.standard.string(forKey: ColorsModel.keyFavouriteColor)
        let net = UserDefaults.standard.string(forKey: ColorsModel.keyNetColor)
        let bord = UserDefaults.standard.string(forKey: ColorsModel.keyBorderColor)
        let back = UserDefaults.standard.string(forKey: ColorsModel.keyBackColor)
        let sback = UserDefaults.standard.string(forKey: ColorsModel.keyStationBackColor)
        let cback = UserDefaults.standard.string(forKey: ColorsModel.keyCountryBackColor)
        
        self.favouriteColor = (fav != nil) ? Color(hex: fav!) : Color.teal
        self.netColor = (net != nil) ? Color(hex: net!) : Color.blue
        self.borderColor = (bord != nil) ? Color(hex: bord!) : Color.accentColor
        self.backColor = (back != nil) ? Color(hex: back!) : Color.mint.opacity(0.4)
        self.stationBackColor = (sback != nil) ? Color(hex: sback!) : Color.white.opacity(0.4)
        self.countryBackColor = (cback != nil) ? Color(hex: cback!) : Color.teal.opacity(0.4)
    }
    
}

extension Color {
    public init(hex: String) {
        self.init(UIColor(hex: hex))
    }

    public func toHex(alpha: Bool = true) -> String? {
        UIColor(self).toHex(alpha: alpha)
    }
}

extension UIColor {
    
    convenience init(hex: String) {
        let trimHex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        let dropHash = String(trimHex.dropFirst()).trimmingCharacters(in: .whitespacesAndNewlines)
        let hexString = trimHex.starts(with: "#") ? dropHash : trimHex
        let ui64 = UInt64(hexString, radix: 16)
        let value = ui64 != nil ? Int(ui64!) : 0
        // #RRGGBB
        var components = (
            R: CGFloat((value >> 16) & 0xff) / 255,
            G: CGFloat((value >> 08) & 0xff) / 255,
            B: CGFloat((value >> 00) & 0xff) / 255,
            a: CGFloat(1)
        )
        if String(hexString).count == 8 {
            // #RRGGBBAA
            components = (
                R: CGFloat((value >> 24) & 0xff) / 255,
                G: CGFloat((value >> 16) & 0xff) / 255,
                B: CGFloat((value >> 08) & 0xff) / 255,
                a: CGFloat((value >> 00) & 0xff) / 255
            )
        }
        self.init(red: components.R, green: components.G, blue: components.B, alpha: components.a)
    }
    
    func toHex(alpha: Bool = true) -> String? {
        guard let components = cgColor.components, components.count >= 3 else {
            return nil
        }
        
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        var a = Float(1.0)
        
        if components.count >= 4 {
            a = Float(components[3])
        }
        
        if alpha {
            return String(format: "%02lX%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255), lroundf(a * 255))
        } else {
            return String(format: "%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
        }
    }
}

