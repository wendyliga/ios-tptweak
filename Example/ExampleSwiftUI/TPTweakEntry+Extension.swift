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
import UIKit

extension TPTweakEntry {
    static let enableTracking = TPTweakEntry(
        category: "Tracking",
        section: "Tracking",
        cell: "Enable Tracking",
        footer: "Turn this on to enable tracking",
        type: .switch(defaultValue: true)
    )

    static let trackingTimeout = TPTweakEntry(
        category: "Tracking",
        section: "Timeout",
        cell: "Max Timeout",
        footer: "Passing this value will timeout tracking request",
        type: .numbers(item: [10, 15, 20], selected: 10)
    )

    static let trackingHistory = TPTweakEntry(
        category: "Tracking",
        section: "Tracking",
        cell: "History",
        footer: nil,
        type: .action({
            // `.action` push into TPTweak's own navigation stack,
            // wrap the SwiftUI view on `UIHostingController` to push it.
            guard let tweakNavigation = findTweakNavigation() else { return }

            let viewController = UIHostingController(rootView: TrackingHistoryView())
            viewController.title = "Tracking History"

            tweakNavigation.pushViewController(viewController, animated: true)
        })
    )

    static let trackingServerLocation = TPTweakEntry(
        category: "Tracking",
        section: "Server",
        cell: "Location",
        footer: "Server to send tracking adta",
        type: .strings(item: ["US", "UK", "SG"], selected: "SG")
    )

    static let trackingUsingLocale = TPTweakEntry(
        category: "Tracking",
        section: "Locale",
        cell: "Using Locale",
        footer: "Enabled this to let the tracker send data about your locale",
        type: .switch(defaultValue: false, completion: { isUsingLocale in
            if isUsingLocale {
                UserDefaults.standard.set(Locale.current.identifier, forKey: "tracker_locale")
            } else {
                UserDefaults.standard.removeObject(forKey: "tracker_locale")
            }
        })
    )

    static let changeLanguage = TPTweakEntry(
        category: "Apperance",
        section: "Language",
        cell: "Language",
        footer: "Change app's language",
        type: .strings(item: ["English", "Spanish", "Indonesia"], selected: "English")
    )
}

/**
 Find the currently visible TPTweak navigation.

 TPTweak could be presented directly by shake, or hosted inside SwiftUI's `sheet`,
 so search the children too instead of only casting the presented view controller.
 */
private func findTweakNavigation() -> TPTweakWithNavigatationViewController? {
    let windowScenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
    let scene = windowScenes.first(where: { $0.activationState == .foregroundActive }) ?? windowScenes.first
    let rootViewController = (scene?.windows.first(where: \.isKeyWindow) ?? scene?.windows.first)?.rootViewController

    func search(_ viewController: UIViewController?) -> TPTweakWithNavigatationViewController? {
        guard let viewController else { return nil }

        if let tweakNavigation = viewController as? TPTweakWithNavigatationViewController {
            return tweakNavigation
        }

        for child in viewController.children {
            if let found = search(child) { return found }
        }

        return search(viewController.presentedViewController)
    }

    return search(rootViewController)
}
