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

struct AuthorizationPermissionView: View {

    weak var delegate: AuthorizationViewDelegate?
    var presentingViewController: UIViewController
    var appIdentifiers = [AppIdentifier]()
    var logoId = String("logo_net_id")
    var headlineText = LocalizableUtil.netIdLocalizable("authorization_view_private_settings")
    var legalText = LocalizableUtil.netIdLocalizable("authorization_view_legal_info_part_one")
    var continueText = LocalizableUtil.netIdLocalizable("authorization_view_agree_and_continue_with_net_id")
    private let bundle = Bundle(for: NetIdService.self)
    private let style = NetIdService.sharedInstance.getLayerStyle()
    @Environment(\.colorScheme) var colorScheme

    @State private var selectedAppIndex = 0
    @State private var showAvailableAppSelection = false

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Image(logoId.isEmpty ? "96x96_n-a" : logoId, bundle: bundle)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 32, alignment: .leading)
                Spacer()
                Button {
                    delegate?.didTapDismiss()
                } label: {
                    Image(systemName: "xmark")
                        .resizable()
                        .scaledToFit()
                        .accentColor(Color("closeButtonColor", bundle: bundle))
                        .frame(height: 14, alignment: .leading)
                }
            }
            Divider().frame(maxHeight:1).background(Color("dividerColor", bundle: bundle))

            Text(headlineText.isEmpty ? LocalizableUtil.netIdLocalizable("authorization_view_private_settings") : headlineText)
                .font(Font.system(size: 16, weight: .semibold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 0)

            VStack(spacing: 10) {
                if (appIdentifiers.count > 1) {
                    Text(legalText.isEmpty ? LocalizableUtil.netIdLocalizable("authorization_view_legal_info_part_one") : legalText).font(Font.system(size: 12, weight: .regular))
                    .foregroundColor(Color("legalInfoColor", bundle: bundle))

                    + Text(
                    LocalizableUtil.netIdLocalizable(
                        "authorization_view_legal_info_select")).underline().font(Font.system(size: 12, weight: .regular))
                    .foregroundColor(Color("legalInfoColor", bundle: bundle))

                    + Text(String(format: LocalizableUtil.netIdLocalizable(
                        "authorization_view_legal_info_part_two"), appIdentifiers[selectedAppIndex].name)).font(Font.system(size: 12, weight: .regular))
                    .foregroundColor(Color("legalInfoColor", bundle: bundle))
                } else if (appIdentifiers.count == 1) {
                    Text(legalText.isEmpty ? LocalizableUtil.netIdLocalizable("authorization_view_legal_info_part_one") : legalText).font(Font.system(size: 12, weight: .regular))
                    .foregroundColor(Color("legalInfoColor", bundle: bundle))

                    + Text(String(format: LocalizableUtil.netIdLocalizable(
                        "authorization_view_legal_info_part_two"), appIdentifiers[selectedAppIndex].name)).font(Font.system(size: 12, weight: .regular))
                    .foregroundColor(Color("legalInfoColor", bundle: bundle))
                } else {
                    Text(legalText.isEmpty ? LocalizableUtil.netIdLocalizable("authorization_view_legal_info_part_one") : legalText).font(Font.system(size: 12, weight: .regular))
                    .foregroundColor(Color("legalInfoColor", bundle: bundle))
 
                    + Text(String(format: LocalizableUtil.netIdLocalizable(
                        "authorization_view_legal_info_part_two"), LocalizableUtil.netIdLocalizable("authorization_view_net_id"))).font(Font.system(size: 12, weight: .regular))
                    .foregroundColor(Color("legalInfoColor", bundle: bundle))
                }
            }
                    .onTapGesture(perform: {
                        if (appIdentifiers.count > 1) {
                            showAvailableAppSelection = true
                        }
                    })
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 0)
                    .padding(.bottom, 8)

            if showAvailableAppSelection {
                ForEach(Array(appIdentifiers.enumerated()), id: \.element.id) { index, result in
                    HStack(spacing: 10) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: result.backgroundColor) ?? Color.white)
                                .frame(width: 40, height: 40)

                            Image(result.icon, bundle: bundle)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 28, height: 28, alignment: .center)
                        }
                        Text(String(format: LocalizableUtil.netIdLocalizable("authorization_view_use_app"), result.name))
                            .kerning(-0.45)
                            .font(Font.system(size: 16, weight: .bold))

                        Spacer()

                        let radioCheckedBinding = Binding<Bool>(get: { self.selectedAppIndex == index }, set: { _ in })

                        RadioButtonView(isChecked: radioCheckedBinding, didSelect: {
                            selectedAppIndex = index
                        })
                    }
                            .padding(.vertical, 10)
                            .background(Color("netIdLayerColor", bundle: bundle))
                            .onTapGesture {
                                selectedAppIndex = index
                            }
                    

                    if index != (appIdentifiers.count - 1) {
                        Divider()
                                .frame(maxHeight:1).background(Color("dividerColor",    bundle: bundle))
                                .padding(.leading, 50)
                                .padding(.trailing, 0)
                    }
                }

            }

            Button {
                var universalLink: String?
                if appIdentifiers.count > selectedAppIndex {
                    let selectedAppIdentifier = appIdentifiers[selectedAppIndex]
                    universalLink = selectedAppIdentifier.iOS.universalLink
                }
                delegate?.didTapContinue(universalLink: universalLink, presentingViewController: presentingViewController, authFlow: NetIdAuthFlow.Permission)
            } label: {
                ZStack {
                    Image("logo_net_id_short", bundle: bundle)
                        .frame(maxWidth: .infinity, maxHeight: 24, alignment: .leading)
                    Text(continueText.isEmpty ? LocalizableUtil.netIdLocalizable("authorization_view_agree_and_continue_with_net_id") : continueText)
                        .kerning(-0.45)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(Color("netIdButtonColor", bundle: bundle))
                        .font(Font.system(size: 18, weight: .semibold))
                }
                .padding(12)
                .background(Color((style == .Solid) ? "netIdOtherOptionsColor" : "netIdTransparentColor", bundle: bundle))
                .cornerRadius(5)
                .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color((style == .Solid) ? "netIdButtonStrokeColor" : "netIdButtonOutlineColor", bundle: bundle)))
            }
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 23)
        .background(Color("netIdLayerColor", bundle: bundle))
    }
}

struct AuthorizationPermissionView_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            AuthorizationPermissionView(presentingViewController: UIViewController(),
                    appIdentifiers: [AppIdentifier(id: 0, name: "GMX", backgroundColor: "#FF402FD2", foregroundColor: "#FFFFFFFF",
                                                   icon: "logo_gmx", typeFaceIcon: "typeface_gmx", iOS: AppDetailsIOS(bundleIdentifier: "test", scheme: "test", universalLink: "test"),
                                                   android: AppDetailsAndroid(applicationId: "test", verifiedAppLink: "test")),
                        AppIdentifier(id: 1, name: "W", backgroundColor: "#FFF7AD0A", foregroundColor: "#FFFFFFFF",
                                icon: "logo_web_de", typeFaceIcon: "typeface_webde",
                                      iOS: AppDetailsIOS(bundleIdentifier: "test", scheme: "test", universalLink: "test"),
                                      android: AppDetailsAndroid(applicationId: "test", verifiedAppLink: "test"))])
                    .onAppear {
                    }
        }
    }
}
