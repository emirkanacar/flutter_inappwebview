//
//  VisibleViewController.swift
//  flutter_inappwebview
//
//  Created by Alexandru Terente on 02.08.2023.
//

import UIKit

extension UIApplication {

    /// Returns the key window belonging to the active window scene.
    ///
    /// `UIApplicationDelegate.window` is not populated for scene-based apps.
    var activeKeyWindow: UIWindow? {
        let windowScenes = connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .filter {
                $0.activationState == .foregroundActive ||
                $0.activationState == .foregroundInactive
            }

        return windowScenes
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
            ?? windowScenes.flatMap { $0.windows }.first
    }

    var visibleViewController: UIViewController? {
        guard let rootViewController = activeKeyWindow?.rootViewController else {
            return nil
        }
        return getVisibleViewController(rootViewController)
    }

    private func getVisibleViewController(_ rootViewController: UIViewController) -> UIViewController? {
        if let presentedViewController = rootViewController.presentedViewController {
            return getVisibleViewController(presentedViewController)
        }
        if let navigationController = rootViewController as? UINavigationController {
            return navigationController.visibleViewController
        }
        if let tabBarController = rootViewController as? UITabBarController {
            return tabBarController.selectedViewController
        }
        return rootViewController
    }
}
