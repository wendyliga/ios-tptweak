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

/**
 Shake to open TPTweak, without having to own the `UIWindow`.

 `TPTweakShakeWindow` requires you to create the app's window yourself, which is impossible on
 scene based apps where the system owns the window, such as SwiftUI's `WindowGroup`.
 This listen to the shake motion on every `UIWindow` instead, so it works on any app lifecycle.

 ```swift
 @main
 struct MyApp: App {
     init() {
         TPTweakShakeDetector.start()
     }

     var body: some Scene {
         WindowGroup { ContentView() }
     }
 }
 ```

 same as `TPTweakShakeWindow`, this only present TPTweak on debug build,
 unless `TPTWEAK_ENABLE_RELEASE_MODE` is set.
 */
public enum TPTweakShakeDetector {
    // MARK: - Interface

    /// title of TPTweak page when presented by shake, `nil` will use the default title.
    public static var title: String? = nil

    /// `true` when shake is currently being listened.
    public static var isEnabled: Bool {
        __isShakeDetectorEnabled
    }

    /**
     Start listening to shake motion, calling this multiple times is safe.

     - Parameter title: title of TPTweak page when presented by shake.
     */
    public static func start(title: String? = nil) {
        if let title {
            Self.title = title
        }

        swizzleMotionIfNeccessary()
        __isShakeDetectorEnabled = true
    }

    /// Stop listening to shake motion.
    public static func stop() {
        __isShakeDetectorEnabled = false
    }

    /**
     Present TPTweak on top of the current screen.

     Useful to open TPTweak from a button, since shaking is not always available(eg. on macOS/Catalyst).

     - Parameter title: title of TPTweak page, `nil` will use the default title.
     */
    public static func present(title: String? = nil) {
        guard let topViewController = UIApplication.topViewController() else { return }

        // TPTweak is already on screen, presenting again will throw
        guard !(topViewController is TPTweakViewController),
              !(topViewController.navigationController is TPTweakWithNavigatationViewController)
        else { return }

        let viewController = TPTweakWithNavigatationViewController()

        if let title {
            viewController.title = title
        }

        topViewController.present(viewController, animated: true)
    }

    // MARK: - Function

    internal static func handleShake(from window: UIWindow) {
        guard __isShakeDetectorEnabled else { return }

        // `TPTweakShakeWindow` already present TPTweak by itself, don't present twice
        guard !(window is TPTweakShakeWindow) else { return }

        guard TPTweakStore.environment.isDebugMode() else { return }

        present(title: title)
    }

    private static func swizzleMotionIfNeccessary() {
        guard !__setupMotionSwizzle else { return }
        __setupMotionSwizzle = true

        let originalSelector = #selector(UIResponder.motionEnded(_:with:))
        let swizzledSelector = #selector(UIWindow.__tptweak_motionEnded(_:with:))

        guard let originalMethod = class_getInstanceMethod(UIWindow.self, originalSelector),
              let swizzledMethod = class_getInstanceMethod(UIWindow.self, swizzledSelector)
        else { return }

        __originalMotionEnded = method_getImplementation(originalMethod)

        // `UIWindow` inherit `motionEnded(_:with:)` from `UIResponder` instead of implementing it,
        // exchanging right away would swap it for every `UIResponder` in the app,
        // adding it to `UIWindow` instead keeps the swizzle scoped to windows only.
        let isAdded = class_addMethod(
            UIWindow.self,
            originalSelector,
            method_getImplementation(swizzledMethod),
            method_getTypeEncoding(swizzledMethod)
        )

        if !isAdded {
            // `UIWindow` already own an implementation, take over it and keep the old one to call later
            __originalMotionEnded = class_replaceMethod(
                UIWindow.self,
                originalSelector,
                method_getImplementation(swizzledMethod),
                method_getTypeEncoding(swizzledMethod)
            )
        }
    }
}

extension UIWindow {
    @objc internal func __tptweak_motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            TPTweakShakeDetector.handleShake(from: self)
        }

        guard let __originalMotionEnded else { return }

        // `UIResponder`'s implementation pass the motion to the next responder by resending `_cmd`,
        // so the original implementation has to be called with the original selector,
        // calling it through a renamed selector will make the next responder throw `doesNotRecognizeSelector`.
        let originalImplementation = unsafeBitCast(__originalMotionEnded, to: TPTweakMotionEndedImplementation.self)
        originalImplementation(self, #selector(UIResponder.motionEnded(_:with:)), motion, event)
    }
}

private typealias TPTweakMotionEndedImplementation = @convention(c) (UIWindow, Selector, UIEvent.EventSubtype, UIEvent?) -> Void

private var __setupMotionSwizzle = false
private var __isShakeDetectorEnabled = false
private var __originalMotionEnded: IMP?
#endif
