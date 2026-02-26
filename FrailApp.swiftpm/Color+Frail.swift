import SwiftUI
import Foundation

extension Color {
    // MARK: - Hex Initializer (must come first)
    init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let length = hexSanitized.count
        let r, g, b, a: CGFloat
        
        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0
            a = 1.0
        } else if length == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0
        } else {
            r = 0
            g = 0
            b = 0
            a = 1.0
        }
        
        self.init(red: r, green: g, blue: b, opacity: a)
    }
    
    // MARK: - Palette
    static let frailBackground = Color(red: 0x08/255.0, green: 0x0A/255.0, blue: 0x12/255.0)
    static let frailPrimaryText = Color(red: 0xF0/255.0, green: 0xED/255.0, blue: 0xE6/255.0)
    static let frailMutedText = Color(red: 0xA8/255.0, green: 0xB4/255.0, blue: 0xC8/255.0)
    static let frailAccent = Color(red: 0x4A/255.0, green: 0x90/255.0, blue: 0xD9/255.0)
    static let frailGold = Color(red: 0xC9/255.0, green: 0xA8/255.0, blue: 0x4C/255.0)
    static let frailAmber = Color(red: 0xD9/255.0, green: 0x7B/255.0, blue: 0x3A/255.0)
    static let frailCrimson = Color(red: 0x8B/255.0, green: 0x1A/255.0, blue: 0x1A/255.0)
    static let frailEmerald = Color(red: 0x4C/255.0, green: 0xAF/255.0, blue: 0x82/255.0)
    static let frailMentorBg = Color(red: 0x0F/255.0, green: 0x15/255.0, blue: 0x25/255.0)
    static let frailMentorBorder = Color(red: 0x1E/255.0, green: 0x2D/255.0, blue: 0x50/255.0)
    
    // MARK: - Nova Colors
    static let novaCenter = Color(red: 0x6E/255.0, green: 0xB5/255.0, blue: 0xFF/255.0)
    static let novaEdge = Color(red: 0x1A/255.0, green: 0x3A/255.0, blue: 0x6B/255.0)
    static let novaGlow = Color(red: 0x4A/255.0, green: 0x90/255.0, blue: 0xD9/255.0)
}

