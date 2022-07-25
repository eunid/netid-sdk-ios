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

struct ContentView: View {

    @EnvironmentObject var serviceViewModel: ServiceViewModel

    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Text("net_id_service_title")
                    .padding()
                    .font(.title2)

            HStack(alignment: .center, spacing: 50) {
                Button("initialize_button_title") {
                    serviceViewModel.initializeNetIdService()
                }
                        .tint(Color.white)
                        .frame(maxWidth: .infinity)
                        .padding(10)
                        .background(Color.green)
                        .cornerRadius(5)

                Circle()
                        .fill(serviceViewModel.initializationStatusColor)
                        .frame(width: 20, height: 20, alignment: .center)
            }
                    .padding(.horizontal, 20)
                    .disabled(!serviceViewModel.initializationEnabled)

            HStack(alignment: .center, spacing: 50) {
                Button("authorize_button_title") {
                    serviceViewModel.authorizeNetIdService()
                }
                        .tint(Color.white)
                        .frame(maxWidth: .infinity)
                        .padding(10)
                        .background(Color.blue)
                        .cornerRadius(5)

                Circle()
                        .fill(serviceViewModel.authenticationStatusColor)
                        .frame(width: 20, height: 20, alignment: .center)
            }
                    .padding(.horizontal, 20)
                    .disabled(!serviceViewModel.authenticationEnabled)

            HStack(alignment: .center, spacing: 50) {
                Button("user_info_button_title") {
                    serviceViewModel.fetchUserInfo()
                }
                        .tint(Color.white)
                        .frame(maxWidth: .infinity)
                        .padding(10)
                        .background(Color.yellow)
                        .cornerRadius(5)

                Circle()
                        .fill(serviceViewModel.userInfoStatusColor)
                        .frame(width: 20, height: 20, alignment: .center)
            }
                    .padding(.horizontal, 20)
                    .disabled(!serviceViewModel.userInfoEnabled)


            ScrollView {
                Text(serviceViewModel.logText)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .padding(.horizontal, 20)
                        .font(Font.system(size: 13))
            }

            HStack(alignment: .center, spacing: 50) {
                Button("end_session_button_title") {
                    serviceViewModel.endSession()
                }
                        .tint(Color.white)
                        .frame(maxWidth: .infinity)
                        .padding(10)
                        .background(Color.red)
                        .cornerRadius(5)
            }
                    .padding(.horizontal, 20)
                    .disabled(!serviceViewModel.endSessionEnabled)
        }
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(ServiceViewModel())
    }
}
