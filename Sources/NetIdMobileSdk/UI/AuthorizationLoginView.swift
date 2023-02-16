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

import SwiftUI

struct AuthorizationLoginView: View {

    weak var delegate: AuthorizationViewDelegate?
    var presentingViewController: UIViewController
    var appIdentifiers = [AppIdentifier]()
    var authFlow: NetIdAuthFlow
    var headlineText = LocalizableUtil.netIdLocalizable("authorization_login_view_email_login")
    var loginText = LocalizableUtil.netIdLocalizable("authorization_login_view_continue_with")
    var continueText = LocalizableUtil.netIdLocalizable("authorization_view_agree_and_continue_with_net_id")
    private let bundle = Bundle.module
    private let style = NetIdService.sharedInstance.getLayerStyle()
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image("logo_net_id_short", bundle: bundle)
                    .scaledToFit()
                    .frame(height: 20)
                    .padding(.leading, 23)
                Text(LocalizableUtil.netIdLocalizable("authorization_login_view_title"))
                    .font(Font.system(size: 14, weight: .medium))
                    .foregroundColor(Color("netIdGrayColor", bundle: bundle))
                Spacer()
            }
            Divider()
                .frame(maxHeight:1).background(Color("dividerColor", bundle: bundle))
                .padding(.horizontal, 23)

            if appIdentifiers.count > 0 {
                HStack {
                    Text(headlineText.isEmpty ? LocalizableUtil.netIdLocalizable("authorization_login_view_email_login") : headlineText)
                        .font(Font.system(size: 18, weight: .semibold))
                        .foregroundColor(Color("netIdBlackWhiteColor", bundle: bundle))
                        .padding(.horizontal, 20)
                    Spacer()
                }
            }
            ForEach(appIdentifiers, id: \.id) { result in
                let logo = (style == .Solid) ? result.icon : result.icon + "_outline"
                let foregroundColor = (style == .Solid) ? Color(hex: result.foregroundColor) : Color("netIdButtonColor", bundle: bundle)
                let outlineColor = (style == .Solid) ? Color(hex: result.backgroundColor) : Color("netIdButtonOutlineColor", bundle: bundle)
                Button {
                    delegate?.didTapContinue(universalLink: result.iOS.universalLink, presentingViewController: presentingViewController, authFlow: authFlow)
                } label: {
                    ZStack {
                        Image(logo, bundle: bundle)
                            .frame(maxWidth: .infinity, maxHeight: 24, alignment: .leading)
                        Text(String(format: loginText.isEmpty ? LocalizableUtil.netIdLocalizable("authorization_login_view_continue_with") : loginText, result.name))
                            .kerning(-0.45)
                            .frame(maxWidth: .infinity)
                            .foregroundColor(foregroundColor)
                            .font(Font.system(size: 18, weight: .semibold))
                    }
                }
                .padding(12)
                .background((style == .Solid) ? Color(hex: result.backgroundColor) : Color("netIdTransparentColor"))
                .cornerRadius(5)
                .overlay(RoundedRectangle(cornerRadius: 5).stroke(outlineColor!))
                .padding(.horizontal, 20)
            }
            
            // If there are not ID applications installed, display a button to use app2web instead.
            if appIdentifiers.isEmpty {
                Button {
                    delegate?.didTapContinue(universalLink: nil, presentingViewController: presentingViewController, authFlow: authFlow)
                } label: {
                    ZStack {
                        Image("logo_net_id_short", bundle: bundle)
                            .frame(maxWidth: .infinity, maxHeight: 24, alignment: .leading)
                        Text(continueText.isEmpty ? LocalizableUtil.netIdLocalizable("authorization_login_view_title") : continueText)
                            .kerning(-0.45)
                            .frame(maxWidth: .infinity)
                            .foregroundColor(Color("authorizationTitleColor", bundle: bundle))
                            .font(Font.system(size: 18, weight: .semibold))
                    }
                }
                .padding(12)
                .background(Color("netIdOtherOptionsColor", bundle: bundle))
                .cornerRadius(5)
                .padding(.horizontal, 20)
                .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color(colorScheme == .dark ? "netIdLayerColor" : "closeButtonGrayColor", bundle: bundle)).padding(.horizontal, 20))
            }
            
            Button {
                delegate?.didTapDismiss()
            } label: {
                Text(String(format: LocalizableUtil.netIdLocalizable("authorization_login_view_close"), "App"))
                    .kerning(-0.45)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(Color("authorizationTitleColor", bundle: bundle))
                    .font(Font.system(size: 18, weight: .semibold))
            }
            .padding(12)
            .background(Color((style == .Solid) ? "netIdContinueColor" : "netIdTransparentColor", bundle: bundle))
            .cornerRadius(5)
            .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color((style == .Solid) ? "netIdContinueColor" : "netIdButtonOutlineColor", bundle: bundle)))
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 20)
        .background(Color("netIdLayerColor", bundle: bundle))
    }
}

struct AuthorizationLoginView_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            AuthorizationLoginView(presentingViewController: UIViewController(),
                    appIdentifiers: [AppIdentifier(id: 0, name: "GMX", backgroundColor: "#FF402FD2", foregroundColor: "#FFFFFFFF",
                                                   icon: "logo_gmx", typeFaceIcon: "typeface_gmx", iOS: AppDetailsIOS(bundleIdentifier: "test", scheme: "test", universalLink: "test"),
                                                   android: AppDetailsAndroid(applicationId: "test", verifiedAppLink: "test")),
                        AppIdentifier(id: 1, name: "W", backgroundColor: "#FFF7AD0A", foregroundColor: "#FFFFFFFF",
                                      icon: "logo_web_de", typeFaceIcon: "typeface_webde", iOS: AppDetailsIOS(bundleIdentifier: "test", scheme: "test", universalLink: "test"),
                                      android: AppDetailsAndroid(applicationId: "test", verifiedAppLink: "test"))], authFlow: NetIdAuthFlow.Login)
        }
    }
}
