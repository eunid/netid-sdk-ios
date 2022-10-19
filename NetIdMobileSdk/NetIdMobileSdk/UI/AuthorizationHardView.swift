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

struct AuthorizationHardView: View {

    var delegate: AuthorizationViewDelegate?
    var presentingViewController: UIViewController
    var appIdentifiers = [AppIdentifier]()
    private let bundle = Bundle(for: NetIdService.self)

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Spacer()
                Image("logo_net_id", bundle: bundle)
                    .resizable()
                    .scaledToFit()
                    .padding(.horizontal, 12)
                    .frame(width: 100, height: 30)
            }
            if appIdentifiers.count == 1 {
                Image(appIdentifiers[0].typeFaceIcon, bundle: bundle)
                    .resizable()
                    .scaledToFit()
                    .padding(.horizontal, 12)
                    .frame(width: 100, height: 30, alignment: .center)
            }
            
            Text(LocalizableUtil.netIdLocalizable("authorization_hard_view_email_login"))
                .font(Font.verdana(size: 16))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            
            ForEach(appIdentifiers, id: \.id) { result in
                Button {
                    delegate?.didTapContinue(destinationScheme: result.iOS.universalLink, presentingViewController: presentingViewController, authFlow: NetIdAuthFlow.Login)
                } label: {
                    Text(String(format: LocalizableUtil.netIdLocalizable("authorization_hard_view_continue_with"), result.name).uppercased())
                        .kerning(1.25)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(Color(hex: result.foregroundColor))
                        .font(Font.robotoMedium(size: 14))
                }
                .padding(12)
                .background(Color(hex: result.backgroundColor))
                .cornerRadius(5)
                .padding(.horizontal, 20)
            }
            //            getButtons(appIdentifiers: appIdentifiers, delegate: delegate!, presentingViewController: presentingViewController)
            
            // If there are not ID applications installed, display a button to use app2web instead.
            if appIdentifiers.isEmpty {
                Button {
                    delegate?.didTapContinue(destinationScheme: nil, presentingViewController: presentingViewController, authFlow: NetIdAuthFlow.Login)
                } label: {
                    Text(LocalizableUtil.netIdLocalizable("authorization_view_agree_and_continue_with_net_id"))
                        .kerning(1.25)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(Color.white)
                        .font(Font.robotoMedium(size: 14))
                }
                .padding(12)
                .background(Color("netIdGreenColor", bundle: bundle))
                .cornerRadius(5)
                .padding(.horizontal, 20)
            }
            
            Button {
                delegate?.didTapDismiss()
            } label: {
                //TODO Get display name from currently running app
                Text(String(format: LocalizableUtil.netIdLocalizable("authorization_hard_view_close"), "App").uppercased())
                    .kerning(1.25)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(Color("authorizationTitleColor", bundle: bundle))
                    .font(Font.robotoMedium(size: 14))
            }
            .padding(12)
            .cornerRadius(5)
            .padding(.horizontal, 20)
            .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color("closeButtonGrayColor", bundle: bundle))
                .padding(.horizontal, 20))
        }
        .padding(.vertical, 20)
        .background(Color.white)
    }
}

func getButtons(appIdentifiers: [AppIdentifier], delegate: AuthorizationViewDelegate, presentingViewController: UIViewController) -> ForEach<[AppIdentifier], Int, some View> /*[any View] */{
    //var buttons: [any View]
    let b = ForEach(appIdentifiers, id: \.id) { result in
        
        Button {
            delegate.didTapContinue(destinationScheme: result.iOS.universalLink, presentingViewController: presentingViewController, authFlow: NetIdAuthFlow.Login)
        } label: {
            Text(String(format: LocalizableUtil.netIdLocalizable("authorization_hard_view_continue_with"), result.name).uppercased())
                    .kerning(1.25)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(Color(hex: result.foregroundColor))
                    .font(Font.robotoMedium(size: 14))
        }
                .padding(12)
                .background(Color(hex: result.backgroundColor))
                .cornerRadius(5)
                .padding(.horizontal, 20)
//        buttons.append(b)
    }
/*    for app in appIdentifiers {
        let button = Button {
            delegate.didTapContinue(destinationScheme: app.iOS.universalLink, presentingViewController: presentingViewController)
        } label: {
            Text(String(format: LocalizableUtil.netIdLocalizable("authorization_hard_view_continue_with"), app.name).uppercased())
                    .kerning(1.25)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(Color(hex: app.foregroundColor))
                    .font(Font.robotoMedium(size: 14))
        }
                .padding(12)
                .background(Color(hex: app.backgroundColor))
                .cornerRadius(5)
                .padding(.horizontal, 20)
        buttons.append(button)
    }*/
    return b
}


struct AuthorizationHardView_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            AuthorizationHardView(presentingViewController: UIViewController(),
                    appIdentifiers: [AppIdentifier(id: 0, name: "GMX", backgroundColor: "#FF402FD2", foregroundColor: "#FFFFFFFF",
                                                   icon: "logo_gmx", typeFaceIcon: "typeface_gmx", iOS: AppDetailsIOS(bundleIdentifier: "test", scheme: "test", universalLink: "test"),
                                                   android: AppDetailsAndroid(applicationId: "test", verifiedAppLink: "test")),
                        AppIdentifier(id: 1, name: "W", backgroundColor: "#FFF7AD0A", foregroundColor: "#FFFFFFFF",
                                      icon: "logo_web_de", typeFaceIcon: "typeface_webde", iOS: AppDetailsIOS(bundleIdentifier: "test", scheme: "test", universalLink: "test"),
                                      android: AppDetailsAndroid(applicationId: "test", verifiedAppLink: "test"))])
                    .onAppear {
                        Font.loadCustomFonts()
                    }
        }
    }
}
