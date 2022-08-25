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
    @State private var showingAlert = false

    var body: some View {
        ZStack {
            VStack(alignment: .center, spacing: 10) {
                Text("net_id_service_title")
                        .padding()
                        .font(.title2)

                HStack(alignment: .center, spacing: 50) {
                    Button {
                        serviceViewModel.initializeNetIdService()
                    } label: {
                        Text("initialize_button_title")
                                .frame(maxWidth: .infinity)
                                .foregroundColor(serviceViewModel.initializationEnabled ? Color.white : Color.gray)
                    }
                            .padding(10)
                            .background(Color.green)
                            .cornerRadius(5)
                            .disabled(!serviceViewModel.initializationEnabled)

                    Circle()
                            .fill(serviceViewModel.initializationStatusColor)
                            .frame(width: 20, height: 20, alignment: .center)
                }
                        .padding(.horizontal, 20)

                HStack(alignment: .center, spacing: 50) {
                    Button {
                        showingAlert = true
                    } label: {
                        Text("authorize_button_title")
                                .frame(maxWidth: .infinity)
                                .foregroundColor(serviceViewModel.authenticationEnabled ? Color.white : Color.gray)
                    }
                            .padding(10)
                            .background(Color.blue)
                            .cornerRadius(5)
                            .disabled(!serviceViewModel.authenticationEnabled)
                            .alert("choose_auth_flow_title", isPresented: $showingAlert) {
                                Button("Soft-Login") {
                                    serviceViewModel.authFlow = .Soft
                                    serviceViewModel.authorizeNetIdService()
                                }
                                Button("Hard-Login") {
                                    serviceViewModel.authFlow = .Hard
                                    serviceViewModel.authorizeNetIdService()
                                }
                            }

                    Circle()
                            .fill(serviceViewModel.authenticationStatusColor)
                            .frame(width: 20, height: 20, alignment: .center)
                }
                        .padding(.horizontal, 20)

                HStack(alignment: .center, spacing: 50) {
                    Button {
                        serviceViewModel.fetchUserInfo()
                    } label: {
                        Text("user_info_button_title")
                                .frame(maxWidth: .infinity)
                                .foregroundColor(serviceViewModel.userInfoEnabled ? Color.white : Color.gray)
                    }
                            .padding(10)
                            .background(Color.yellow)
                            .cornerRadius(5)
                            .disabled(!serviceViewModel.userInfoEnabled)

                    Circle()
                            .fill(serviceViewModel.userInfoStatusColor)
                            .frame(width: 20, height: 20, alignment: .center)
                }
                        .padding(.horizontal, 20)

                Text("permission_management_title")
                        .padding()
                        .font(.body)
                        .frame(maxWidth: .infinity, alignment: .topLeading)

                HStack(alignment: .center, spacing: 25) {
                    Button {
                        serviceViewModel.fetchPermissions()
                    } label: {
                        Text("fetch_permissions_button_title")
                                .frame(maxWidth: .infinity)
                                .foregroundColor(serviceViewModel.fetchPermissionsEnabled ? Color.white : Color.gray)
                    }
                            .padding(10)
                            .background(Color.orange)
                            .cornerRadius(5)
                            .disabled(!serviceViewModel.fetchPermissionsEnabled)
                    Button {
                        serviceViewModel.updatePermission()
                    } label: {
                        Text("update_permission_button_title")
                                .frame(maxWidth: .infinity)
                                .foregroundColor(serviceViewModel.updatePermissionEnabled ? Color.white : Color.gray)
                    }
                            .padding(10)
                            .background(Color.orange)
                            .cornerRadius(5)
                            .disabled(!serviceViewModel.updatePermissionEnabled)
                }
                        .padding(.horizontal, 20)

                Text("log_text_title")
                        .padding()
                        .font(.body)
                        .frame(maxWidth: .infinity, alignment: .topLeading)

                ScrollView {
                    Text(serviceViewModel.logText)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                            .padding(.horizontal, 20)
                            .font(Font.system(size: 13))
                }

                Button {
                    serviceViewModel.endSession()
                } label: {
                    Text("end_session_button_title")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(serviceViewModel.endSessionEnabled ? Color.white : Color.gray)
                }
                        .padding(10)
                        .background(Color.red)
                        .cornerRadius(5)
                        .disabled(!serviceViewModel.endSessionEnabled)
            }
                    .padding(.horizontal, 20)
                    .zIndex(1)

            if serviceViewModel.authorizationViewVisible {

                Rectangle()
                        .foregroundColor(Color.black.opacity(0.5))
                        .ignoresSafeArea()
                        .transition(.opacity)
                        .zIndex(2)

                VStack {
                    Spacer()
                    serviceViewModel.getAuthorizationView()
                            .padding(.bottom, 20)
                            .cornerRadius(12)
                            .shadow(radius: 7)
                }
                        .transition(.move(edge: .bottom))
                        .ignoresSafeArea()
                        .zIndex(3)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(ServiceViewModel())
    }
}
