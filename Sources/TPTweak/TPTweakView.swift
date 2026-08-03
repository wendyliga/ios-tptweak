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

#if canImport(SwiftUI) && canImport(UIKit)
import SwiftUI
import UIKit

/**
 TPTweak page as a SwiftUI `View`.

 Put it inside your own `sheet`, `NavigationLink` or anywhere a `View` is expected.

 ```swift
 .sheet(isPresented: $isTweakPresented) {
     TPTweakView()
 }
 ```
 */
@available(iOS 13.0, *)
public struct TPTweakView: UIViewControllerRepresentable {
    // MARK: - Values

    private let title: String?
    private let showDefaultDismissButton: Bool

    // MARK: - Life Cycle

    /**
     - Parameters:
        - title: title of TPTweak page, `nil` will use the default title.
        - showDefaultDismissButton: show TPTweak's own close button. defaulted to `false`,
          since SwiftUI's `sheet` is dismissed by its own binding, and TPTweak's close button will not update it.
     */
    public init(title: String? = nil, showDefaultDismissButton: Bool = false) {
        self.title = title
        self.showDefaultDismissButton = showDefaultDismissButton
    }

    // MARK: - UIViewControllerRepresentable

    public func makeUIViewController(context _: Context) -> TPTweakWithNavigatationViewController {
        let viewController = TPTweakWithNavigatationViewController(showDefaultDismissButton: showDefaultDismissButton)
        viewController.title = title

        return viewController
    }

    public func updateUIViewController(_: TPTweakWithNavigatationViewController, context _: Context) {}
}

@available(iOS 13.0, *)
extension View {
    /**
     Present TPTweak as a sheet.

     ```swift
     ContentView()
         .tptweak(isPresented: $isTweakPresented)
     ```
     */
    public func tptweak(isPresented: Binding<Bool>, title: String? = nil) -> some View {
        sheet(isPresented: isPresented) {
            TPTweakView(title: title)
        }
    }

    /**
     Open TPTweak when the device is shaked.

     Works on SwiftUI's `WindowGroup`, where the window is owned by the system and
     `TPTweakShakeWindow` can not be installed.

     ```swift
     WindowGroup {
         ContentView()
             .tptweakShakeToPresent()
     }
     ```

     same as `TPTweakShakeWindow`, this only present TPTweak on debug build,
     unless `TPTWEAK_ENABLE_RELEASE_MODE` is set.
     */
    public func tptweakShakeToPresent(title: String? = nil) -> some View {
        onAppear {
            TPTweakShakeDetector.start(title: title)
        }
    }
}
#endif
