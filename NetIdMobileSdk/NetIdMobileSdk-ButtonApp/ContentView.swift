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
import NetIdMobileSdk

struct ContentView: View {
    @EnvironmentObject var serviceViewModel: ServiceViewModel
    @State var selectedStyle:NetIdButtonStyle = .WhiteSolid

    var body: some View {
        VStack {
            Picker("Style", selection: $selectedStyle) {
                Text("White").tag(NetIdButtonStyle.WhiteSolid)
                Text("Green").tag(NetIdButtonStyle.GreenSolid)
                Text("Outline").tag(NetIdButtonStyle.GrayOutline)
            }
            .pickerStyle(SegmentedPickerStyle())
            .background(Color.white)
            .onChange(of: selectedStyle) {style in
                NetIdService.sharedInstance.setButtonStyle(style)
                serviceViewModel.logText += "Switched style\n"
            }
            
            VStack {
                Text("Permission flow")
                NetIdService.sharedInstance.continueButtonPermissionFlow()
                    .disabled(serviceViewModel.endSessionEnabled)
                ForEach((NetIdService.sharedInstance.getKeysForAccountProviderApps()), id: \.self) { key in
                    NetIdService.sharedInstance.permissionButtonForAccountProviderApp(key: key, continueText: key)
                        .disabled(serviceViewModel.endSessionEnabled)
                }
            }
            .padding()
            VStack {
                Text("Login flow")
                NetIdService.sharedInstance.continueButtonLoginFlow(authFlow: .Login)
                    .foregroundColor(serviceViewModel.endSessionEnabled ? Color.white : Color.gray)
                    .disabled(serviceViewModel.endSessionEnabled)
                ForEach(NetIdService.sharedInstance.getKeysForAccountProviderApps(), id: \.self) { key in
                    NetIdService.sharedInstance.loginButtonForAccountProviderApp(authFlow: .Login, key: key)
                        .disabled(serviceViewModel.endSessionEnabled)
                }
            }
            .padding()
            
            Text("log_text_title")
            ScrollView {
                Text(serviceViewModel.logText)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .padding(.horizontal, 20)
                    .font(Font.system(size: 13))
                    .accessibilityIdentifier("LogView")
            }
            
            Button {
                serviceViewModel.endSession()
            } label: {
                Text("end_session_button_title")
                    .frame(maxWidth: .infinity, maxHeight: 40)
                    .foregroundColor(serviceViewModel.endSessionEnabled ? Color.white : Color.gray)
            }
            .background(Color.red)
            .cornerRadius(5)
            .padding(20)
            .disabled(!serviceViewModel.endSessionEnabled)
        }
        .background(Image("netiD_short")
            .resizable(resizingMode:.tile)
            .frame(minWidth: 0, maxWidth: .infinity)
            .edgesIgnoringSafeArea(.all)
            .opacity(0.2))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
