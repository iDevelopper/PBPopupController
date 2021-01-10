//
//  UIViewController+Support.swift
//  PBPopupController
//
//  Created by Patrick BODET on 16/03/2018.
//  Copyright © 2018-2020 Patrick BODET. All rights reserved.
//

import Foundation
import UIKit
import ObjectiveC

//_setContentOverlayInsets:
private let sCoOvBase64 = "X3NldENvbnRlbnRPdmVybGF5SW5zZXRzOg=="
//_updateContentOverlayInsetsFromParentIfNecessary
private let uCOIFPINBase64 = "X3VwZGF0ZUNvbnRlbnRPdmVybGF5SW5zZXRzRnJvbVBhcmVudElmTmVjZXNzYXJ5"
//_hideBarWithTransition:isExplicit:
private let hBWTiEBase64 = "X2hpZGVCYXJXaXRoVHJhbnNpdGlvbjppc0V4cGxpY2l0Og=="
//_showBarWithTransition:isExplicit:
private let sBWTiEBase64 = "X3Nob3dCYXJXaXRoVHJhbnNpdGlvbjppc0V4cGxpY2l0Og=="
//_setToolbarHidden:edge:duration:
private let sTHedBase64 = "X3NldFRvb2xiYXJIaWRkZW46ZWRnZTpkdXJhdGlvbjo="
//hideBarWithTransition:
private let hBWTBase64 = "aGlkZUJhcldpdGhUcmFuc2l0aW9uOg=="
//showBarWithTransition:
private let sBWTBase64 = "c2hvd0JhcldpdGhUcmFuc2l0aW9uOg=="

public extension UIViewController
{
    internal struct AssociatedKeys {
        static var popupBar: PBPopupBar?
        static var bottomBar: UIView?
        static var popupController: PBPopupController?
        static var popupContainerViewController: UIViewController?
        static var popupContentViewController: UIViewController?
        static var popupContentView: PBPopupContentView?
        static var isTabBarHiddenDuringTransition = "isTabBarHiddenDuringTransition"
        static var additionalSafeAreaInsetsBottomForContainer = "additionalSafeAreaInsetsBottomForContainer"
        static var popupAdditionalSafeAreaInsets = "popupAdditionalSafeAreaInsets"
    }
    
    internal var isTabBarHiddenDuringTransition: Bool! {
        get {
            let isHidden = objc_getAssociatedObject(self, &AssociatedKeys.isTabBarHiddenDuringTransition) as? NSNumber
            return isHidden?.boolValue ?? false
        }
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self, &AssociatedKeys.isTabBarHiddenDuringTransition, NSNumber(value: newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    /**
     The popup bar managed by the system. (read-only).
     
     - SeeAlso: `PBPopupBar`.
     */
    @objc internal(set) weak var popupBar: PBPopupBar! {
        get {
            if objc_getAssociatedObject(self, &AssociatedKeys.popupBar) != nil {
                return objc_getAssociatedObject(self, &AssociatedKeys.popupBar) as? PBPopupBar
            }
            else {
                return self.popupController.pb_popupBar()
            }
        }
        
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(
                    self,
                    &AssociatedKeys.popupBar,
                    newValue as PBPopupBar,
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )
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
            if objc_getAssociatedObject(self, &AssociatedKeys.bottomBar) != nil {
                return objc_getAssociatedObject(self, &AssociatedKeys.bottomBar) as? UIView
            }
            else {
                return self.popupController.pb_bottomBar()
            }
        }
        
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(
                    self,
                    &AssociatedKeys.bottomBar,
                    newValue as UIView,
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )
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
            if objc_getAssociatedObject(self, &AssociatedKeys.popupController) != nil {
                return objc_getAssociatedObject(self, &AssociatedKeys.popupController) as? PBPopupController
            }
            else {
                return pb_popupController()
            }
        }
        
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(
                    self,
                    &AssociatedKeys.popupController,
                    newValue as PBPopupController,
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )
            }
        }
    }
    
    /**
     Returns the container (presenting) view controller for the popup bar, and for the presented view controller (popupContentViewController). May be `UIViewController`, `UINavigationController`, `UITabBarController` or a custom container view controller. (read-only).

     - SeeAlso: `additionalSafeAreaInsetsBottomForContainer`.
     */
    @objc internal(set) weak var popupContainerViewController: UIViewController! {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.popupContainerViewController) as? UIViewController
        }
        
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(
                    self,
                    &AssociatedKeys.popupContainerViewController,
                    newValue as UIViewController,
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )
            }
        }
    }
    
    /**
     Returns the popup content view controller of the container. If there is no popup bar presentation, the property will be `nil`. (read-only).
     */
    @objc internal(set) weak var popupContentViewController: UIViewController! {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.popupContentViewController) as? UIViewController
        }
        
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(
                    self,
                    &AssociatedKeys.popupContentViewController,
                    newValue as UIViewController?,
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )
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
            if objc_getAssociatedObject(self, &AssociatedKeys.popupContentView) != nil {
                return objc_getAssociatedObject(self, &AssociatedKeys.popupContentView) as? PBPopupContentView
            }
            else {
                return self.popupController.pb_popupContentView()
            }
        }
        
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(
                    self,
                    &AssociatedKeys.popupContentView,
                    newValue as PBPopupContentView?,
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
            if let height = objc_getAssociatedObject(self, &AssociatedKeys.additionalSafeAreaInsetsBottomForContainer) as? NSNumber {
                return CGFloat(height.floatValue)
            }
            return 0
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.additionalSafeAreaInsetsBottomForContainer, NSNumber(value: Float(newValue)), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    @objc internal var popupAdditionalSafeAreaInsets: UIEdgeInsets {
        get {
            if let insets = objc_getAssociatedObject(self, &AssociatedKeys.popupAdditionalSafeAreaInsets) as? NSValue {
                return insets.uiEdgeInsetsValue
            }
            return UIEdgeInsets.zero
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.popupAdditionalSafeAreaInsets, NSValue(uiEdgeInsets: newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
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
        
        self.configurePopupBarFromBottomBar()
        
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
        if objc_getAssociatedObject(self, &AssociatedKeys.popupBar) != nil {
            self.popupController._closePopupAnimated(false) {
                self.popupController._dismissPopupBarAnimated(animated) {
                    self.popupController.popupPresentationController = nil
                    self.popupController.popupPresentationInteractiveController = nil
                    self.popupController.popupDismissalInteractiveController = nil
                    self.popupController = nil
                    self._cleanupPopup()
                    completion?()
                }
            }
        }
        else {
            completion?()
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
        self.popupBar.inheritsVisualStyleFromBottomBar = true
        self.popupBar.updatePopupBarAppearance()
    }
}

public extension UIViewController
{
    internal func getSubviewsOfView(view: UIView) -> [UIView] {
        var subviewArray = [UIView]()
        for subview in view.subviews {
            subviewArray += self.getSubviewsOfView(view: subview)
            subviewArray.append(subview)
        }
        return subviewArray
    }
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

internal func _PBPopupDecodeBase64String(base64String: String?) -> String? {
    if let anOptions = Data(base64Encoded: base64String ?? "", options: []) {
        return String(data: anOptions, encoding: .utf8)
    }
    return nil
}
