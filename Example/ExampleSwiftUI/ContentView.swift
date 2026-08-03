// Copyright 2022-2025 Tokopedia. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import SwiftUI
import TPTweak

internal struct ContentView: View {
    @State private var isTweakPresented = false

    // TPTweak store value on UserDefaults, observing it will refresh the view everytime a tweak is changed.
    @State private var storeVersion = 0

    internal var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    Text("Shake the phone or use ⌘⌃z on simulator to open TPTweak")

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Current Value")
                            .font(.system(size: 14, weight: .bold))

                        Text(currentValue)
                            .id(storeVersion)
                    }

                    Button("Open TPTweak") {
                        isTweakPresented = true
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
            }
            .navigationBarTitle("Content View")
        }
        .navigationViewStyle(.stack)
        // present TPTweak as a sheet, on top of shake to open
        .tptweak(isPresented: $isTweakPresented)
        .onReceive(NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)) { _ in
            storeVersion += 1
        }
    }

    private var currentValue: String {
        """
        Language: \(TPTweakEntry.changeLanguage.getValue(String.self) ?? "-")
        Tracking status: \(TPTweakEntry.enableTracking.getValue(Bool.self) ?? false)
        Tracking server location: \(TPTweakEntry.trackingServerLocation.getValue(String.self) ?? "-")
        Tracking max timeout: \(TPTweakEntry.trackingTimeout.getValue(Int.self) ?? 0)

        Tracking locale is active: \(TPTweakEntry.trackingUsingLocale.getValue(Bool.self) ?? false)
        Tracking locale identifer: \((UserDefaults.standard.value(forKey: "tracker_locale") as? String) ?? "no locale")
        """
    }
}

internal struct TrackingHistoryView: View {
    internal var body: some View {
        Text("Tracking History View")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground))
    }
}
