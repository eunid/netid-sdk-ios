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

import Foundation
import SwiftUI

struct RadioButtonView: View {

    @Binding var isChecked: Bool
    let didSelect: (() -> Void)?

    var body: some View {
        Group {
            if isChecked {
                ZStack {
                    Circle()
                            .fill(Color.white)
                            .overlay(Circle().stroke(Color.blue, lineWidth: 2))
                            .frame(width: 15, height: 15)
                    Circle()
                            .fill(Color.blue)
                            .frame(width: 8, height: 8)
                }
            } else {
                Circle()
                        .fill(Color.white)
                        .frame(width: 15, height: 15)
                        .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                        .onTapGesture {
                            didSelect?()
                        }
            }
        }
    }
}

struct RadioButtonView_Previews: PreviewProvider {

    static var previews: some View {
        @State var checked = true
        
        return Group {
            RadioButtonView(isChecked: $checked, didSelect: nil)
        }
    }
}
