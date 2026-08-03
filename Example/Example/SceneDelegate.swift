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

import TPTweak
import UIKit

internal final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    internal var window: UIWindow?

    internal func scene(_ scene: UIScene, willConnectTo _: UISceneSession, options _: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        // register TPTweakShakeWindow to enable openning TPTweak from shaking the device.
        // on scene based app the window belongs to the scene, so build it here instead of on `AppDelegate`.
        let window = TPTweakShakeWindow(windowScene: windowScene)

        let viewController = ViewController()
        let nav = UINavigationController(rootViewController: viewController)
        nav.navigationBar.isTranslucent = false
        nav.navigationBar.backgroundColor = .red

        window.rootViewController = nav
        window.makeKeyAndVisible()

        self.window = window
    }
}
