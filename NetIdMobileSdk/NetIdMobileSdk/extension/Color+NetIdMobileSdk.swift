//
// Created by Tobias Riesbeck on 07/26/2022.
//

import Foundation
import SwiftUI

extension Color {

    static var netIdGreenColor = Color(red: 118 / 255.0, green: 184 / 255.0, blue: 42 / 255.0)

    static var authorizationTitleColor = Color(red: 82 / 255.0, green: 82 / 255.0, blue: 82 / 255.0)
    static var legalInfoColor = Color(red: 41 / 255.0, green: 41 / 255.0, blue: 41 / 255.0)
    static var closeButtonGrayColor = Color(red: 0, green: 0, blue: 0, opacity: 0.44)

    public init?(hex: String) {
        let r, g, b: CGFloat

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255

                    self.init(red: r, green: g, blue: b)
                    return
                }
            }
        }

        return nil
    }
}
