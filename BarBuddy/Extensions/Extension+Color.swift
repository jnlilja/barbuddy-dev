//
//  Extension+Color.swift
//  BarBuddy
//
//  Created by Gwinyai Nyatsoka on 8/5/2025.
//

import SwiftUI

extension Color {
    /// Create a Color from a hex string.
    /// - Parameter hex: 6- or 8-character hex string, with or without leading “#”:
    ///   - RRGGBB (opaque)
    ///   - AARRGGBB (with alpha)
    init(hex: String) {
        // Trim whitespace/newlines and remove leading “#” if present
        let hexString = hex
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")
        
        // Scanner to convert hex string into integer
        var hexValue: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&hexValue)
        
        let hasAlpha = hexString.count == 8
        let divisor = Double(255)
        
        let red:   Double
        let green: Double
        let blue:  Double
        let alpha: Double
        
        if hasAlpha {
            alpha = Double((hexValue & 0xFF_00_00_00) >> 24) / divisor
            red   = Double((hexValue & 0x00_FF_00_00) >> 16) / divisor
            green = Double((hexValue & 0x00_00_FF_00) >> 8)  / divisor
            blue  = Double( hexValue & 0x00_00_00_FF       ) / divisor
        } else {
            alpha = 1.0
            red   = Double((hexValue & 0xFF_00_00) >> 16) / divisor
            green = Double((hexValue & 0x00_FF_00) >> 8)  / divisor
            blue  = Double( hexValue & 0x00_00_FF       ) / divisor
        }
        
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }
}

