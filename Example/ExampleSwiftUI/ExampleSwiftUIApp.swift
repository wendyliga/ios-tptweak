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

@main
internal struct ExampleSwiftUIApp: App {
    internal init() {
        // register TPTweak Entry
        TPTweakEntry.enableTracking.register()
        TPTweakEntry.trackingTimeout.register()
        TPTweakEntry.trackingHistory.register()
        TPTweakEntry.trackingServerLocation.register()
        TPTweakEntry.trackingUsingLocale.register()
        TPTweakEntry.changeLanguage.register()
    }

    internal var body: some Scene {
        WindowGroup {
            ContentView()
                // `WindowGroup`'s window is owned by SwiftUI, so `TPTweakShakeWindow` can not be used,
                // this listen to the shake motion on the window instead.
                .tptweakShakeToPresent()
        }
    }
}
