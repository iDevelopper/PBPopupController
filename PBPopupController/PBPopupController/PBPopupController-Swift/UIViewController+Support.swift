//
//  UIViewController+Support.swift
//  PBPopupController
//
//  Created by Patrick BODET on 16/03/2018.
//  Copyright © 2018-2024 Patrick BODET. All rights reserved.
//

import Foundation
import UIKit
import ObjectiveC

public extension UIViewController
{
    internal struct AssociatedKeys {
        static var enablePopupColorsDebug = "enablePopupColorsDebug"
        static var enablePopupBarColorsDebug = "enablePopupBarColorsDebug"
        static var usePopupBarSmoothGradient = "usePopupBarSmoothGradient"
        static var usePopupBarLegacyShadow = "usePopupBarLegacyShadow"
        static var popupBar: PBPopupBar?
        static var bottomBar: UIView?
        
        static var bottomBarAppearance: UIBarAppearance?
        
        static var popupController: PBPopupController?
        static var popupContainerViewController: UIViewController?
        static var popupCloseButton: PBPopupCloseButton?
        static var popupContentViewController: UIViewController?
        static var popupContentView: PBPopupContentView?
        static var isBottomBarHiddenDuringTransition = "isBottomBarHiddenDuringTransition"
        static var hidesPopupBarWhenPushed = "hidesPopupBarWhenPushed"
        static var popupBarIsHidden = "popupBarIsHidden"
        static var popupBarWasHidden = "popupBarWasHidden"
        static var additionalSafeAreaInsetsBottomForContainer = "additionalSafeAreaInsetsBottomForContainer"
        static var popupAdditionalSafeAreaInsets = "popupAdditionalSafeAreaInsets"
    }
    
    // https://github.com/atrick/swift-evolution/blob/diagnose-implicit-raw-bitwise/proposals/nnnn-implicit-raw-bitwise-conversion.md#workarounds-for-common-cases
    
    internal static func getAssociatedPopupBarFor(_ controller: UIViewController) -> PBPopupBar? {
        let rv = withUnsafePointer(to: &AssociatedKeys.popupBar) {
                objc_getAssociatedObject(controller, $0) as? PBPopupBar
        }
        return rv
    }
    
    internal static func getAssociatedBottomBarFor(_ controller: UIViewController) -> UIView? {
        let rv = withUnsafePointer(to: &AssociatedKeys.bottomBar) {
                objc_getAssociatedObject(controller, $0) as? UIView
        }
        return rv
    }
    
    internal static func getAssociatedPopupControllerFor(_ controller: UIViewController) -> PBPopupController? {
        let rv = withUnsafePointer(to: &AssociatedKeys.popupController) {
                objc_getAssociatedObject(controller, $0) as? PBPopupController
        }
        return rv
    }
    
    internal static func getAssociatedPopupContentViewControllerFor(_ controller: PBPopupController) -> UIViewController? {
        let rv = withUnsafePointer(to: &AssociatedKeys.popupController) {
                objc_getAssociatedObject(controller, $0) as? UIViewController
        }
        return rv
    }
    
    /**
     A Boolean value indicating whether the popup content displays the view layout with colors. The default value is `false`. If necessary, change the value to `true`..
     */
    @objc var enablePopupColorsDebug: Bool {
        get {
            let isEnabled = withUnsafePointer(to: &AssociatedKeys.enablePopupColorsDebug) {
                objc_getAssociatedObject(self, $0) as? NSNumber
            }
            return isEnabled?.boolValue ?? false
        }
        set {
            withUnsafePointer(to: &AssociatedKeys.enablePopupColorsDebug) {
                objc_setAssociatedObject(
                    self,
                    $0,
                    NSNumber(value: newValue),
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )
            }
        }
    }
    
    /**
     A Boolean value indicating whether the popup bar displays the view layout with colors. The default value is `false`. If necessary, change the value to `true` before accessing or configuring the popup bar.
     */
    @objc var enablePopupBarColorsDebug: Bool {
        get {
            let isEnabled = withUnsafePointer(to: &AssociatedKeys.enablePopupBarColorsDebug) {
                objc_getAssociatedObject(self, $0) as? NSNumber
            }
            return isEnabled?.boolValue ?? false
        }
        set {
            withUnsafePointer(to: &AssociatedKeys.enablePopupBarColorsDebug) {
                objc_setAssociatedObject(
                    self,
                    $0,
                    NSNumber(value: newValue),
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )
            }
        }
    }
    
    /**
     A Boolean value indicating whether the floating popup bar uses smooth gradient.  The default value is `true`. If necessary, change the value to `false` before accessing or configuring the popup bar.
     
     - SeeAlso: [smooth-gradient](https://github.com/janselv/smooth-gradient).
     */
    @objc var usePopupBarSmoothGradient: Bool {
        get {
            let isEnabled = withUnsafePointer(to: &AssociatedKeys.usePopupBarSmoothGradient) {
                    objc_getAssociatedObject(self, $0) as? NSNumber
            }
            return isEnabled?.boolValue ?? false
        }
        set {
            withUnsafePointer(to: &AssociatedKeys.usePopupBarSmoothGradient) {
                objc_setAssociatedObject(
                    self,
                    $0,
                    NSNumber(value: newValue),
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )
            }
        }
    }
    
    /**
     A Boolean value indicating whether the floating popup bar uses legacy shadow (otherwise it uses NSShadow with shadowPath).  The default value is `false`. If necessary, change the value to `true` before accessing or configuring the popup bar.
     */
    @objc var usePopupBarLegacyShadow: Bool {
        get {
            let isEnabled = withUnsafePointer(to: &AssociatedKeys.usePopupBarLegacyShadow) {
                    objc_getAssociatedObject(self, $0) as? NSNumber
            }
            return isEnabled?.boolValue ?? false
        }
        set {
            withUnsafePointer(to: &AssociatedKeys.usePopupBarLegacyShadow) {
                objc_setAssociatedObject(
                    self,
                    $0,
                    NSNumber(value: newValue),
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )
            }
        }
    }
    
    /**
     The popup bar managed by the system. (read-only).
     
     - SeeAlso: `PBPopupBar`.
     */
    @objc internal(set) weak var popupBar: PBPopupBar! {
        get {
            let rv = withUnsafePointer(to: &AssociatedKeys.popupBar) {
                    objc_getAssociatedObject(self, $0) as? PBPopupBar
            }
            if rv == nil {
                return self.popupController.pb_popupBar()
            }
            return rv
        }
        
        set {
            if let newValue = newValue {
                withUnsafePointer(to: &AssociatedKeys.popupBar) {
                    objc_setAssociatedObject(
                        self,
                        $0,
                        newValue as PBPopupBar,
                        .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                    )
                }
            }
        }
    }

    /**
     Returns a view to attach the popup bar to.
     
     A default implementation is provided for `UIViewController`, `UINavigationController` and `UITabBarController`.
     The default implmentation for `UIViewController` returns an invisible `UIView` instance, docked to the bottom of the screen. For `UINavigationController`, the toolbar is returned. For `UITabBarController`, the tab bar is returned.
     */
    @objc internal(set) weak var bottomBar: UIView! {
        get {
            let rv = withUnsafePointer(to: &AssociatedKeys.bottomBar) {
                    objc_getAssociatedObject(self, $0) as? UIView
            }
            if rv == nil {
                return self.popupController.pb_bottomBar()
            }
            return rv
        }
        
        set {
            if let newValue = newValue {
                withUnsafePointer(to: &AssociatedKeys.bottomBar) {
                    objc_setAssociatedObject(
                        self,
                        $0,
                        newValue as UIView,
                        .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                    )
                }
            }
        }
    }

    @objc internal var bottomBarAppearance: UIBarAppearance! {
        get {
            let rv = withUnsafePointer(to: &AssociatedKeys.bottomBarAppearance) {
                    objc_getAssociatedObject(self, $0) as? UIBarAppearance
            }
            return rv
        }
        
        set {
            if let newValue = newValue {
                withUnsafePointer(to: &AssociatedKeys.bottomBarAppearance) {
                    objc_setAssociatedObject(
                        self,
                        $0,
                        newValue as UIBarAppearance,
                        .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                    )
                }
            }
            else {
                withUnsafePointer(to: &AssociatedKeys.bottomBarAppearance) {
                    objc_setAssociatedObject(self, $0, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                }
            }
        }
    }
    
    /**
     The popup controller (read-only).
     
     - SeeAlso:
     - `PBPopupController.dataSource`.
     - `PBPopupController.delegate`.
     - `PBPopupController.popupPresentationState`.
     */
    @objc internal(set) weak var popupController: PBPopupController! {
        get {
            let rv = withUnsafePointer(to: &AssociatedKeys.popupController) {
                    objc_getAssociatedObject(self, $0) as? PBPopupController
            }
            if rv == nil {
                return pb_popupController()
            }
            return rv
        }
        
        set {
            if let newValue = newValue {
                withUnsafePointer(to: &AssociatedKeys.popupController) {
                    objc_setAssociatedObject(
                        self,
                        $0,
                        newValue as PBPopupController,
                        .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                    )
                }
            }
        }
    }
    
    /**
     Returns the container (presenting) view controller for the popup bar, and for the presented view controller (popupContentViewController). May be `UIViewController`, `UINavigationController`, `UITabBarController` or a custom container view controller. (read-only).
     
     - SeeAlso: `additionalSafeAreaInsetsBottomForContainer`.
     */
    @objc internal(set) weak var popupContainerViewController: UIViewController! {
        get {
            let rv = withUnsafePointer(to: &AssociatedKeys.popupContainerViewController) {
                    objc_getAssociatedObject(self, $0) as? UIViewController
            }
            if rv == nil {
                return self.popupContainerViewController()
            }
            return rv
        }
        
        set {
            if let newValue = newValue {
                withUnsafePointer(to: &AssociatedKeys.popupContainerViewController) {
                    objc_setAssociatedObject(
                        self,
                        $0,
                        newValue as UIViewController,
                        .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                    )
                }
            }
        }
    }
    
    /**
     Returns the container (presenting) view controller for the popup bar, and for the presented view controller (popupContentViewController). May be `UIViewController`, `UINavigationController`, `UITabBarController` or a custom container view controller. (read-only).
     
     - SeeAlso: `popupContainerViewController`.
     */
    @objc internal(set) weak var popupCloseButton: PBPopupCloseButton! {
        get {
            let rv = withUnsafePointer(to: &AssociatedKeys.popupCloseButton) {
                objc_getAssociatedObject(self, $0) as? PBPopupCloseButton
            }
            return rv
        }
        
        set {
            if let newValue = newValue {
                withUnsafePointer(to: &AssociatedKeys.popupCloseButton) {
                    objc_setAssociatedObject(
                        self,
                        $0,
                        newValue as PBPopupCloseButton,
                        .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                    )
                }
            }
        }
    }
    
    /**
     Returns the popup content view controller of the container. If there is no popup bar presentation, the property will be `nil`. (read-only).
     */
    @objc internal(set) weak var popupContentViewController: UIViewController! {
        get {
            return withUnsafePointer(to: &AssociatedKeys.popupContentViewController) {
                    objc_getAssociatedObject(self, $0) as? UIViewController
            }
        }
        
        set {
            if let newValue = newValue {
                withUnsafePointer(to: &AssociatedKeys.popupContentViewController) {
                    objc_setAssociatedObject(
                        self,
                        $0,
                        newValue as UIViewController?,
                        .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                    )
                }
                newValue.popupContainerViewController = self
                self.popupController.preparePopupContentViewControllerForPresentation()
            }
        }
    }
    
    /**
     Returns the view where is embedded the popupContentViewController's view for presentation. This view has a optional close button and a visual effect view with an optional effect. (read-only).
     
     - SeeAlso: `PBPopupContentView`.
     */
    @objc internal(set) weak var popupContentView: PBPopupContentView! {
        get {
            let rv = withUnsafePointer(to: &AssociatedKeys.popupContentView) {
                    objc_getAssociatedObject(self, $0) as? PBPopupContentView
            }
            if rv == nil {
                return self.popupController.pb_popupContentView()
            }
            return rv
        }
        
        set {
            if let newValue = newValue {
                withUnsafePointer(to: &AssociatedKeys.popupContentView) {
                    objc_setAssociatedObject(
                        self,
                        $0,
                        newValue as PBPopupContentView?,
                        .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                    )
                }
            }
        }
    }
    
    internal var isBottomBarHiddenDuringTransition: Bool! {
        get {
            let isHidden = withUnsafePointer(to: &AssociatedKeys.isBottomBarHiddenDuringTransition) {
                    objc_getAssociatedObject(self, $0) as? NSNumber
            }
            return isHidden?.boolValue ?? false
        }
        set {
            if let newValue = newValue {
                withUnsafePointer(to: &AssociatedKeys.isBottomBarHiddenDuringTransition) {
                    objc_setAssociatedObject(
                        self,
                        $0,
                        NSNumber(value: newValue),
                        .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                    )
                }
            }
        }
    }
    
    /**
     A Boolean value indicating whether the popup bar is hidden when the view controller is pushed on to a navigation controller.

     - SeeAlso: `hidesBottomBarWhenPushed`.
     */
    @objc var hidesPopupBarWhenPushed: Bool {
        get {
            let isHidden = withUnsafePointer(to: &AssociatedKeys.hidesPopupBarWhenPushed) {
                    objc_getAssociatedObject(self, $0) as? NSNumber
            }
            return isHidden?.boolValue ?? false
        }
        set {
            withUnsafePointer(to: &AssociatedKeys.hidesPopupBarWhenPushed) {
                objc_setAssociatedObject(
                    self,
                    $0,
                    NSNumber(value: newValue),
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )
            }
        }
    }
    
    internal var popupBarIsHidden: Bool {
        get {
            let isHidden = withUnsafePointer(to: &AssociatedKeys.popupBarIsHidden) {
                    objc_getAssociatedObject(self, $0) as? NSNumber
            }
            return isHidden?.boolValue ?? false
        }
        set {
            withUnsafePointer(to: &AssociatedKeys.popupBarIsHidden) {
                objc_setAssociatedObject(
                    self,
                    $0,
                    NSNumber(value: newValue),
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )
            }
        }
    }
    
    internal var popupBarWasHidden: Bool {
        get {
            let isHidden = withUnsafePointer(to: &AssociatedKeys.popupBarWasHidden) {
                    objc_getAssociatedObject(self, $0) as? NSNumber
            }
            return isHidden?.boolValue ?? false
        }
        set {
            withUnsafePointer(to: &AssociatedKeys.popupBarWasHidden) {
                objc_setAssociatedObject(
                    self,
                    $0,
                    NSNumber(value: newValue),
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )
            }
        }
    }
    
    /**
     Custom insets that you specify to modify the container view controller's safe area (usefull for a custom container). Use this property to adjust the safe area bottom edge inset value of this view controller's views by the specified amount.
     */
    @objc var additionalSafeAreaInsetsBottomForContainer: CGFloat {
        get {
            let height = withUnsafePointer(to: &AssociatedKeys.additionalSafeAreaInsetsBottomForContainer) {
                    objc_getAssociatedObject(self, $0) as? NSNumber
            }
            if let height = height {
                return CGFloat(height.floatValue)
            }
            return 0
        }
        set {
            withUnsafePointer(to: &AssociatedKeys.additionalSafeAreaInsetsBottomForContainer) {
                objc_setAssociatedObject(
                    self,
                    $0,
                    NSNumber(value: Float(newValue)),
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )
            }
        }
    }
    
    @objc internal var popupAdditionalSafeAreaInsets: UIEdgeInsets {
        get {
            let insets = withUnsafePointer(to: &AssociatedKeys.popupAdditionalSafeAreaInsets) {
                    objc_getAssociatedObject(self, $0) as? NSValue
            }
            if let insets = insets {
                return insets.uiEdgeInsetsValue
            }
            return UIEdgeInsets.zero
        }
        set {
            withUnsafePointer(to: &AssociatedKeys.popupAdditionalSafeAreaInsets) {
                objc_setAssociatedObject(
                    self,
                    $0,
                    NSValue(uiEdgeInsets: newValue),
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )
            }
        }
    }
    
    /**
     Presents an interactive popup bar in the container's view hierarchy and optionally opens the popup in the same animation. The popup bar is attached to the container's bottom bar (see `popupContainerViewController`).
     
     You may call this method multiple times with different controllers, triggering replacement to the popup content view and update to the popup bar, if popup is open or bar presented, respectively.
     
     The provided controller is retained by the system and will be released once a different controller is presented or when the popup bar is dismissed.
     
     - Parameter controller: The presented view controller for popup presentation.
     - Parameter openPopup: Pass `true` to open the popup in the same animation; otherwise, pass `false`.
     - Parameter animated: Pass `true` to animate the presentation; otherwise, pass `false`.
     - Parameter completion: The block to execute after the presentation finishes. This block has no return value and takes no parameters. You may specify nil for this parameter.
     
     - SeeAlso: `PBPopupBar.customPopupBarViewController` for a custom popup bar view controller.
     `PBPopupController.dataSource` for a custom bottom bar view.
     `presentPopupBar(withPopupContentViewController:animated:completion:)`.
     */
    @objc func presentPopupBar(withPopupContentViewController controller: UIViewController!, openPopup: Bool, animated: Bool, completion: (() -> Swift.Void)? = nil) {
        self.presentPopupBar(withPopupContentViewController: controller, animated: openPopup ? false : animated) {
            if openPopup == true {
                self.openPopup(animated: animated, completion: {
                    completion?()
                })
            }
            else {
                completion?()
            }
        }
    }
    
    /**
     Presents an interactive popup bar in the container's view hierarchy. The popup bar is attached to the container's bottom bar (see `popupContainerViewController`).
     
     You may call this method multiple times with different controllers, triggering replacement to the popup content view and update to the popup bar, if popup is open or bar presented, respectively.
     
     The provided controller is retained by the system and will be released once a different controller is presented or when the popup bar is dismissed.
     
     - Parameter controller: The presented view controller for popup presentation.
     - Parameter animated: Pass `true` to animate the presentation; otherwise, pass `false`.
     - Parameter completion: The block to execute after the presentation finishes. This block has no return value and takes no parameters. You may specify nil for this parameter.
     
     - SeeAlso: `PBPopupBar.customPopupBarViewController` for a custom popup bar view controller.
     `PBPopupController.dataSource` for a custom bottom bar view.
     `presentPopupBar(withPopupContentViewController:openPopup:animated:completion:)`.
     */
    @objc func presentPopupBar(withPopupContentViewController controller: UIViewController!, animated: Bool, completion: (() -> Swift.Void)? = nil) {
        
        assert(controller != nil, "Content view controller cannot be nil.")
        if controller == nil {
            NSException.raise(NSExceptionName.internalInconsistencyException, format: "Content view controller cannot be nil.", arguments: getVaList([]))
        }
        self.popupContentViewController = controller
        controller.popupContainerViewController = self
        controller.popupCloseButton = self.popupContentView.popupCloseButton

        controller.view.translatesAutoresizingMaskIntoConstraints = true
        controller.view.autoresizingMask = []
        controller.view.frame = self.view.bounds
        controller.view.clipsToBounds = false
        
        self.popupContentView.popupContentViewController = controller
        
        // TODO: SwiftUI
        // SwiftUI: The popup content view must be in the responder chain for the preferences to work.
        if NSStringFromClass(type(of: controller).self).contains("PBPopupUIContentController") {
            self.popupContentView.insertSubview(controller.view, at: 0)
            self.view.insertSubview(self.popupContentView, at: 0)
        }
        //
        
        controller.view.setNeedsLayout()
        controller.view.layoutIfNeeded()

        self.popupController._presentPopupBarAnimated(animated) {
            completion?()
        }
    }
    
    /**
     Dismisses the popup presentation, closing the popup if open and dismissing the popup bar.
     
     - Parameters:
     - animated: Pass `true` to animate the presentation; otherwise, pass `false`.
     - completion: The block to execute after the presentation finishes. This block has no return value and takes no parameters. You may specify nil for this parameter.
     */
    @objc func dismissPopupBar(animated: Bool, completion: (() -> Swift.Void)? = nil) {
        if UIViewController.getAssociatedPopupBarFor(self) != nil {
            self.popupController._closePopupAnimated(false) {
                self.popupController._dismissPopupBarAnimated(animated) {
                    DispatchQueue.main.async {
                        self.popupController.popupPresentationController = nil
                        self.popupController.popupPresentationInteractiveController = nil
                        self.popupController.popupDismissalInteractiveController = nil
                        self._cleanupPopup()
                        completion?()
                    }
                }
            }
        }
        else {
            completion?()
        }
    }
    
    /**
     Hide the popup bar.
     
     - Parameters:
     - animated: Pass `true` to animate the presentation; otherwise, pass `false`.
     - completion: The block to execute after the presentation finishes. This block has no return value and takes no parameters. You may specify nil for this parameter.
     */
    @objc func hidePopupBar(animated: Bool, completion: (() -> Swift.Void)? = nil) {
        if UIViewController.getAssociatedPopupBarFor(self) != nil {
            self.popupController._hidePopupBarAnimated(animated) {
                completion?()
            }
        }
        else {
            completion?()
        }
    }
    
    /**
     Show the popup bar.
     
     - Parameters:
     - animated: Pass `true` to animate the presentation; otherwise, pass `false`.
     - completion: The block to execute after the presentation finishes. This block has no return value and takes no parameters. You may specify nil for this parameter.
     */
    @objc func showPopupBar(animated: Bool, completion: (() -> Swift.Void)? = nil) {
        if UIViewController.getAssociatedPopupBarFor(self) != nil {
            self.popupController._showPopupBarAnimated(animated) {
                completion?()
            }
        }
        else {
            completion?()
        }
    }
    
    /**
     Presents an interactive popup view controller in the container's view hierarchy. The popup bar is not visible and the popup is attached or not to the container's bottom bar (see `popupContainerViewController`) depending on the `isFloating` parameter.
     
     You may call this method multiple times with different controllers, triggering replacement to the popup content view and update to the popup bar, if popup is open or bar presented, respectively.
     
     The provided controller is retained by the system and will be released once a different controller is presented or when the popup bar is dismissed.
     
     - Parameter controller: The presented view controller for popup presentation.
     - Parameter size: The popup content view size (optional). May be set by the controller in viewDidLayoutSubviews.
     - Parameter isFloating: A Boolean value that indicates whether the popup is floating (`true`) or not (`false`).
     - Parameter animated: Pass `true` to animate the presentation; otherwise, pass `false`.
     - Parameter completion: The block to execute after the presentation finishes. This block has no return value and takes no parameters. You may specify nil for this parameter.
     
     - SeeAlso: `PBPopupBar.customPopupBarViewController` for a custom popup bar view controller.
     `PBPopupController.dataSource` for a custom bottom bar view.
     `presentPopupBar(withPopupContentViewController:openPopup:animated:completion:)`.
     */
    @objc func presentPopup(withPopupContentViewController controller: UIViewController!, size: CGSize = .zero, isFloating: Bool = true, animated: Bool, completion: (() -> Swift.Void)? = nil) {
        assert(controller != nil, "Content view controller cannot be nil.")
        if controller == nil {
            NSException.raise(NSExceptionName.internalInconsistencyException, format: "Content view controller cannot be nil.", arguments: getVaList([]))
        }
        self.popupContentView.popupIgnoreDropShadowView = false
        self.popupContentView.popupPresentationStyle = .popup
        self.popupContentView.popupContentSize = CGSize(width: size.width, height: size.height)
        self.popupContentView.isFloating = isFloating

        self.popupContentViewController = controller
        controller.popupContainerViewController = self
        controller.popupCloseButton = self.popupContentView.popupCloseButton

        controller.view.translatesAutoresizingMaskIntoConstraints = true
        controller.view.autoresizingMask = []
        controller.view.frame = self.view.bounds
        controller.view.clipsToBounds = false
        
        self.popupContentView.popupContentViewController = controller
        
        // TODO: SwiftUI
        // SwiftUI: The popup content view must be in the responder chain for the preferences to work.
        if NSStringFromClass(type(of: controller).self).contains("PBPopupUIContentController") {
            self.popupContentView.insertSubview(controller.view, at: 0)
            self.view.insertSubview(self.popupContentView, at: 0)
        }
        //
        
        controller.view.setNeedsLayout()
        controller.view.layoutIfNeeded()
        
        self.popupController._presentPopupAnimated(animated) {
            completion?()
        }
    }
    
    /**
     Dismisses the popup presentation, closing the popup if open.
     
     - Parameters:
     - animated: Pass `true` to animate the presentation; otherwise, pass `false`.
     - completion: The block to execute after the presentation finishes. This block has no return value and takes no parameters. You may specify nil for this parameter.
     */
    @objc func dismissPopup(animated: Bool, completion: (() -> Swift.Void)? = nil) {
        self.popupController._dismissPopupAnimated(animated) {
            DispatchQueue.main.async {
                self.popupController.popupPresentationController = nil
                self.popupController.popupDismissalInteractiveController = nil
                self._cleanupPopup()
                completion?()
            }
        }
    }
    
    /**
     Opens the popup, displaying the content view controller's view.
     
     - Parameters:
     - animated: Pass `true` to animate the presentation; otherwise, pass `false`.
     - completion: The block to execute after the presentation finishes. This block has no return value and takes no parameters. You may specify nil for this parameter.
     */
    @objc func openPopup(animated: Bool, completion: (() -> Swift.Void)? = nil) {
        self.popupController._openPopupAnimated(animated) {
            completion?()
        }
    }
    
    /**
     Closes the popup, hiding the content view controller's view.
     
     - Parameters:
     - animated: Pass `true` to animate the presentation; otherwise, pass `false`.
     - completion: The block to execute after the presentation finishes. This block has no return value and takes no parameters. You may specify nil for this parameter.
     */
    @objc func closePopup(animated: Bool, completion: (() -> Swift.Void)? = nil) {
        self.popupController._closePopupAnimated(animated) {
            completion?()
        }
    }
    
    /**
     Call this method to update the popup bar appearance (style, tint color, etc.) according to its docking view. You should call this after updating the docking view.
     If the popup bar's `inheritsVisualStyleFromBottomBar` property is set to `false`, this method has no effect.
     
     - SeeAlso: `PBPopupBar.inheritsVisualStyleFromBottomBar`.
     */
    @objc func updatePopupBarAppearance() {
        self.bottomBarAppearance = nil
        self.popupBar.updatePopupBarAppearance()
    }
}

public extension UIViewController
{
    func popupContainerViewController(for viewController: UIViewController? = nil) -> UIViewController? {
        let controller = viewController ?? self
        if let rv = UIViewController.getAssociatedPopupControllerFor(controller) {
            return rv.containerViewController
        }
        if controller.parent == nil {
            return nil
        }
        return popupContainerViewController(for: controller.parent!)
    }
    
    internal func getSubviewsOfView(view: UIView) -> [UIView] {
        var subviewArray = [UIView]()
        for subview in view.subviews {
            subviewArray += self.getSubviewsOfView(view: subview)
            subviewArray.append(subview)
        }
        return subviewArray
    }
    
    internal func getAllSubviews<T: UIView>(view: UIView) -> [T] {
        return view.subviews.flatMap { subView -> [T] in
            var result = getAllSubviews(view: subView) as [T]
            if let view = subView as? T {
                result.append(view)
            }
            return result
        }
    }
}
