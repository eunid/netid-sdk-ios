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

/**
 The main view of the sample application.
 It consits of several buttons, that represent the different steps during an authorization process. Additionally, feedback is logged to  text view.
 */
struct ContentView: View {

    @EnvironmentObject var serviceViewModel: ServiceViewModel
    @State private var showingAlert = false
    @State private var extraClaimShippingAddress = false
    @State private var extraClaimBirthdate = false
    @State var selectedStyle:NetIdLayerStyle = .Solid

    var body: some View {
            ZStack {
                VStack(alignment: .center, spacing: 10) {
                    Text("net_id_service_title")
                        .padding()
                        .font(.title2)
                    
                    HStack(alignment: .center, spacing: 50) {
                        Button {
                            serviceViewModel.initializeNetIdService(
                                extraClaimShippingAddress: extraClaimShippingAddress,
                                extraClaimBirthdate: extraClaimBirthdate)
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
                    
                    VStack(alignment: .center, spacing: 10) {
                        Text("net_id_service_extra_claims")
                            .padding()
                            .font(Font.system(size: 14))
                            .frame(maxWidth: .infinity, alignment: .topLeading)
                        
                        HStack(alignment: .center, spacing: 25) {
                            Toggle(isOn: $extraClaimShippingAddress) {
                                Text("shipping_address").font(Font.system(size: 11))
                            }.disabled(!serviceViewModel.initializationEnabled)
                            
                            Toggle(isOn: $extraClaimBirthdate) {
                                Text("birthdate").font(Font.system(size: 11))
                            }.disabled(!serviceViewModel.initializationEnabled)
                        }
                    }
                    
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
                            .accessibilityIdentifier("LogView")
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
                        .onTapGesture {
                            NetIdService.sharedInstance.didTapDismiss()
                        }
                    
                    VStack {
                        Spacer()
                        serviceViewModel.getAuthorizationView()
                            .padding(.bottom, 12)
                            .cornerRadius(12)
                            .shadow(radius: 7)
                    }
                    .padding(.bottom, -12)
                    .transition(.move(edge: .bottom))
                    .ignoresSafeArea()
                    .zIndex(3)
                }
                
                if showingAlert {
                    Rectangle()
                        .foregroundColor(Color.black.opacity(0.5))
                        .ignoresSafeArea()
                        .transition(.opacity)
                        .zIndex(2)
                        .onTapGesture {
                            showingAlert.toggle()
                        }
                    VStack {
                        Text("choose_auth_flow_title")
                            .foregroundColor(Color.black)
                            .padding()
                        
                        Button(action: {
                            serviceViewModel.authFlow = .Permission
                            showingAlert.toggle()
                            serviceViewModel.authorizeNetIdService()
                        }) {Text("Permission")}
                            .padding(5)
             
                        Button(action: {
                            serviceViewModel.authFlow = .Login
                            showingAlert.toggle()
                            serviceViewModel.authorizeNetIdService()
                        }) {Text("Login")}
                            .padding(5)
             
                        Button(action: {
                            serviceViewModel.authFlow = .LoginPermission
                            showingAlert.toggle()
                            serviceViewModel.authorizeNetIdService()
                        }) {Text("Login + Permission")}
                            .padding(10)
                    }
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .padding(.vertical, 90)
                    .padding(.horizontal, 80)
                    .zIndex(3)
                }

            }
            Picker("Style", selection: $selectedStyle) {
                Text("Solid").tag(NetIdLayerStyle.Solid)
                Text("Outline").tag(NetIdLayerStyle.Outline)
            }
            .pickerStyle(SegmentedPickerStyle())
            .onChange(of: selectedStyle) {style in
                NetIdService.sharedInstance.setLayerStyle(style)
                serviceViewModel.logText += "Switched style\n"
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(ServiceViewModel())
    }
}
