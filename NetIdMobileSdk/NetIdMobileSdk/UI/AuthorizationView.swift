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

struct AuthorizationView: View {

    var delegate: AuthorizationViewDelegate?
    
    private let bundle = Bundle(for: NetIdService.self)
    
    var body: some View {
        VStack(spacing: 10) {
            Image("logo_net_id", bundle: bundle)
            .resizable()
            .scaledToFit()
            .frame(width: 100, height: 30, alignment: .center)
            
            Text(LocalizableUtil.netIdLocalizable("authorization_view_private_settings"))
                .multilineTextAlignment(.center)
                .font(Font.ibmPlexSansSemiBold(size: 16))

            Text(LocalizableUtil.netIdLocalizable("authorization_view_legal_info"))
                .font(Font.ibmPlexSansMedium(size: 10))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)

            Button(LocalizableUtil.netIdLocalizable("authorization_view_agree_and_continue_with_net_id")) {
                delegate?.didTapContinue(bundleIdentifier: nil)
            }
            .frame(maxWidth: .infinity)
            .padding(12)
            .background(Color.green)
            .cornerRadius(5)
            .padding(.horizontal, 20)
            .foregroundColor(Color.white)
            
            Button(LocalizableUtil.netIdLocalizable("authorization_view_close")) {
                delegate?.didTapDismiss()
            }
            .frame(maxWidth: .infinity)
            .padding(12)
            .background(Color.white)
            .cornerRadius(5)
            .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray))
            .padding(.horizontal, 20)
            .foregroundColor(Color.gray)
        }
    }
}

struct AuthorizationView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AuthorizationView()
        }
    }
}
