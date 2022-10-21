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

struct AuthorizationSoftView: View {

    var delegate: AuthorizationViewDelegate?
    var presentingViewController: UIViewController
    var appIdentifiers = [AppIdentifier]()
    private let bundle = Bundle(for: NetIdService.self)

    @State private var selectedAppIndex = 0
    @State private var showAvailableAppSelection = false

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Image("logo_net_id", bundle: bundle)
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
                        .accentColor(Color("legalInfoColor", bundle: bundle))
                        .frame(height: 14, alignment: .leading)
                }
            }
            Divider()

            Text(LocalizableUtil.netIdLocalizable("authorization_view_private_settings"))
                .font(Font.system(size: 16, weight: .semibold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 0)

            //TODO  optimize this
            VStack(spacing: 10) {
                if (appIdentifiers.count > 1) {
                    Text(String(format: LocalizableUtil.netIdLocalizable("authorization_view_legal_info_part_one"),
                            appIdentifiers[selectedAppIndex].name)).font(Font.system(size: 12, weight: .regular))
                            .foregroundColor(Color("legalInfoColor", bundle: bundle))
                            + Text(
                            LocalizableUtil.netIdLocalizable(
                                    "authorization_view_legal_info_select")).underline().font(Font.system(size: 12, weight: .regular))
                            .foregroundColor(Color("legalInfoColor", bundle: bundle))

                            + Text(LocalizableUtil.netIdLocalizable(
                            "authorization_view_legal_info_part_two")).font(Font.system(size: 12, weight: .regular))
                            .foregroundColor(Color("legalInfoColor", bundle: bundle))
                } else if (appIdentifiers.count == 1) {
                    Text(String(format: LocalizableUtil.netIdLocalizable("authorization_view_legal_info_part_one"),
                            appIdentifiers[selectedAppIndex].name)).font(Font.system(size: 12, weight: .regular))
                            .foregroundColor(Color("legalInfoColor", bundle: bundle))

                            + Text(LocalizableUtil.netIdLocalizable(
                            "authorization_view_legal_info_part_two")).font(Font.system(size: 12, weight: .regular))
                            .foregroundColor(Color("legalInfoColor", bundle: bundle))
                } else {
                    Text(String(format: LocalizableUtil.netIdLocalizable("authorization_view_legal_info_part_one"),
                            LocalizableUtil.netIdLocalizable("authorization_view_net_id"))).font(Font.system(size: 12, weight: .regular))
                            .foregroundColor(Color("legalInfoColor", bundle: bundle))

                            + Text(LocalizableUtil.netIdLocalizable(
                                "authorization_view_legal_info_part_two")).font(Font.system(size: 12, weight: .regular))
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
                                .padding(.leading, 50)
                                .padding(.trailing, 0)
                    }
                }

            }

            Button {
                var destinationScheme: String?
                if appIdentifiers.count > selectedAppIndex {
                    let selectedAppIdentifier = appIdentifiers[selectedAppIndex]
                    destinationScheme = selectedAppIdentifier.iOS.universalLink
                }
                delegate?.didTapContinue(destinationScheme: destinationScheme, presentingViewController: presentingViewController, authFlow: NetIdAuthFlow.Permission)
            } label: {
                Image("logo_net_id_short", bundle: bundle)
                    .frame(height: 24)
                Text(LocalizableUtil.netIdLocalizable("authorization_view_agree_and_continue_with_net_id"))
                        .kerning(1.25)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(Color("authorizationTitleColor", bundle: bundle))
                        .font(Font.system(size: 18, weight: .semibold))
            }
                    .padding(12)
                    .cornerRadius(5)
                    .background(Color("netIdOtherOptionsColor", bundle: bundle))
                    .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color("closeButtonGrayColor", bundle: bundle)))
            

        }
        .padding(.vertical, 20)
        .padding(.horizontal, 23)
        .background(Color("netIdLayerColor", bundle: bundle))
    }
}

struct AuthorizationSoftView_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            AuthorizationSoftView(presentingViewController: UIViewController(),
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
