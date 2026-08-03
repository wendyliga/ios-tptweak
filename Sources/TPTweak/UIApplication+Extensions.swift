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

#if canImport(UIKit)
import UIKit

extension UIApplication {
    /**
     Window to attach TPTweak's UI into.

     `keyWindow` is deprecated since iOS 13 and returns `nil` on scene based apps(including SwiftUI's `WindowGroup`),
     so resolve the window from the active `UIWindowScene` first and only fallback to `keyWindow` on older iOS.
     */
    internal static var activeWindow: UIWindow? {
        if #available(iOS 13.0, *) {
            let windowScenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
            let scene = windowScenes.first(where: { $0.activationState == .foregroundActive }) ?? windowScenes.first

            if let window = scene?.windows.first(where: { $0.isKeyWindow }) ?? scene?.windows.first {
                return window
            }
        }

        return UIApplication.shared.keyWindow
    }

    internal class func topViewController(controller: UIViewController? = UIApplication.activeWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}
#endif

