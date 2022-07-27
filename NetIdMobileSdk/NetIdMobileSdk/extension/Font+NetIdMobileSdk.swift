// Copyright 2022 European netID Foundation (https://enid.foundation)
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Foundation
import SwiftUI

extension Font {

    private struct Constants {
        static let ibmPlexSansSemiBoldFontName = "IBMPlexSans-SemiBold"
        static let robotoMediumFontName = "Roboto-Medium"
        static let verdanaFontName = "Verdana"
        static let fontsExtension = "ttf"
    }

    static func ibmPlexSansSemiBold(size: CGFloat) -> Font {
        Font.custom(Constants.ibmPlexSansSemiBoldFontName, size: size)
    }

    static func robotoMedium(size: CGFloat) -> Font {
        Font.custom(Constants.robotoMediumFontName, size: size)
    }

    static func verdana(size: CGFloat) -> Font {
        Font.custom(Constants.verdanaFontName, size: size)
    }

    static func loadCustomFonts() {
        loadCustomFont(fontName: Constants.ibmPlexSansSemiBoldFontName)
        loadCustomFont(fontName: Constants.robotoMediumFontName)
    }

    private static func loadCustomFont(fontName: String) {
        if let fontUrl = Bundle(for: NetIdService.self).url(forResource: fontName, withExtension: Constants.fontsExtension),
           let dataProvider = CGDataProvider(url: fontUrl as CFURL),
           let newFont = CGFont(dataProvider) {
            var error: Unmanaged<CFError>?
            if !CTFontManagerRegisterGraphicsFont(newFont, &error) {
                Logger.shared.error("Error registering font with name " + fontName)
            } else {
                Logger.shared.debug("Successfully registered font with name " + fontName)
            }
        } else {
            Logger.shared.error("Error registering font with name " + fontName)
        }
    }
}
