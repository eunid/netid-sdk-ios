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
    
    // TODO Add localizables
    
    @State private var infoText = "Indem Sie Ihre Einwilligung erteilen, geben Sie uns die Erlaubnis, Sie beim Besuch dieses Werbeangebots als netID-Nutzer..."
    
    @State private var netIdButtonText = "Zustimmen und weiter mit netID"
    
    var body: some View {
        VStack(spacing: 10) {
        Image("logo_net_id", bundle: Bundle(identifier: "de.netid.mobile.sdk.NetIdMobileSdk"))
            .resizable()
            .scaledToFit()
            .frame(width: 100, height: 30, alignment: .center)
            
            Text("Privatsphäre-Einstellungen sicher speichern")
                .multilineTextAlignment(.center)
            
            // TODO Use a dynamic height
            TextEditor(text: $infoText)
                .frame(minWidth: 0,minHeight: 0, maxHeight: 100)
                .multilineTextAlignment(.center)
            
            Button("Zustimmen und weiter mit netID") {
                // TODO Handle button tap
            }
            .frame(maxWidth: .infinity)
            .padding(12)
            .background(Color.green)
            .cornerRadius(5)
            .padding(.horizontal, 20)
            .foregroundColor(Color.white)
            
            Button("Schließen") {
                // TODO Handle button tap
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
