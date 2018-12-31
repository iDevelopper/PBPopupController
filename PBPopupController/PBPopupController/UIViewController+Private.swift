//
//  UIViewController+Private.swift
//  PBPopupController
//
//  Created by Patrick BODET on 15/04/2018.
//  Copyright © 2018 Patrick BODET. All rights reserved.
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

public extension UITabBarController {
    private static let swizzleImplementation: Void = {
        let instance = UITabBarController.self()
        
        let aClass: AnyClass! = object_getClass(instance)
        
        var originalMethod: Method!
        var swizzledMethod: Method!
        
        originalMethod = class_getInstanceMethod(aClass, #selector(setViewControllers(_ :animated:)))
        swizzledMethod = class_getInstanceMethod(aClass, #selector(pb_setViewControllers(_ :animated:)))
        if let originalMethod = originalMethod, let swizzledMethod = swizzledMethod {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
        
        //_hideBarWithTransition:isExplicit:
        var selName = _PBPopupDecodeBase64String(base64String: hBWTiEBase64)!
        var selector = NSSelectorFromString(selName)
        originalMethod = class_getInstanceMethod(aClass, selector)
        swizzledMethod = class_getInstanceMethod(aClass, #selector(_hBWT(t:iE:)))
        if let originalMethod = originalMethod, let swizzledMethod = swizzledMethod {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
        
        //_showBarWithTransition:isExplicit:
        selName = _PBPopupDecodeBase64String(base64String: sBWTiEBase64)!
        selector = NSSelectorFromString(selName)
        originalMethod = class_getInstanceMethod(aClass, selector)
        swizzledMethod = class_getInstanceMethod(aClass, #selector(_sBWT(t:iE:)))
        if let originalMethod = originalMethod, let swizzledMethod = swizzledMethod {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }()
    
    /**
     :nodoc:
     */
    @objc public static func tbc_swizzle() {
        _ = self.swizzleImplementation
    }
    
    //_hideBarWithTransition:isExplicit:
    @objc private func _hBWT(t: Int, iE: Bool) {
        self.isTabBarHiddenDuringTransition = true
        
        self.view.layoutIfNeeded()
        
        self._hBWT(t: t, iE: iE)
        
        if (t > 0) {
            let rv = objc_getAssociatedObject(self, &AssociatedKeys.popupBar) as? PBPopupBar
            if (rv != nil) {
                self.bottomBar.isHidden = true
            }
        }
    }
    
    //_showBarWithTransition:isExplicit:
    @objc private func _sBWT(t: Int, iE: Bool) {
        self.isTabBarHiddenDuringTransition = false
        
        self.view.layoutIfNeeded()
        
        self._sBWT(t: t, iE: iE)
        
        if (t > 0) {
            let rv = objc_getAssociatedObject(self, &AssociatedKeys.popupBar) as? PBPopupBar
            if (rv != nil) {
                self.bottomBar.isHidden = false
            }
        }
    }
    
    @objc private func pb_setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        if #available(iOS 12.0, *) {
            for obj in viewControllers {
                _LNPopupSupportFixInsetsForViewController(obj, false, self.viewControllers?.first?.additionalSafeAreaInsets.bottom ?? 0.0)
            }
        }
        self.pb_setViewControllers(viewControllers, animated: animated)
    }
}

internal extension UITabBarController {
    @objc internal override func _animateBottomBarToHidden( _ hidden: Bool) {
        let height = self.tabBar.frame.height
        if height > 0.0 {
            if hidden == false {
                self.tabBar.frame.origin.y = self.view.bounds.height - height
            }
            else {
                self.tabBar.frame.origin.y = self.view.bounds.height
            }
        }
    }
    
    @objc internal override func _setBottomBarPosition( _ position: CGFloat) {
        let height = self.tabBar.frame.height
        if height > 0.0 {
            self.tabBar.frame.origin.y = position
        }
    }
    
    @objc internal override func insetsForBottomBar() -> UIEdgeInsets {
        if #available(iOS 11.0, *) {
            return self.tabBar.isHidden == false ? UIEdgeInsets.zero : self.view.window?.safeAreaInsets ?? UIEdgeInsets.zero
        } else {
            return UIEdgeInsets.zero
        }
    }
    
    @objc internal override func defaultFrameForBottomBar() -> CGRect {
        var bottomBarFrame = self.tabBar.frame
        let bottomBarSizeThatFits = self.tabBar.sizeThatFits(CGSize.zero)
        
        bottomBarFrame.size.height = max(bottomBarFrame.size.height, bottomBarSizeThatFits.height)
        
        bottomBarFrame.origin = CGPoint(x: 0, y: self.view.bounds.size.height - (self.isTabBarHiddenDuringTransition ? 0.0 : bottomBarFrame.size.height))

        return bottomBarFrame
    }
}

public extension UINavigationController {
    private static let swizzleImplementation: Void = {
        let instance = UINavigationController.self()
        
        let aClass: AnyClass! = object_getClass(instance)
        
        var originalMethod: Method!
        var swizzledMethod: Method!
        
        originalMethod = class_getInstanceMethod(aClass, #selector(pushViewController(_ :animated:)))
        swizzledMethod = class_getInstanceMethod(aClass, #selector(pb_pushViewController(_ :animated:)))
        if let originalMethod = originalMethod, let swizzledMethod = swizzledMethod {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
        
        originalMethod = class_getInstanceMethod(aClass, #selector(setViewControllers(_ :animated:)))
        swizzledMethod = class_getInstanceMethod(aClass, #selector(pb_setViewControllers(_ :animated:)))
        if let originalMethod = originalMethod, let swizzledMethod = swizzledMethod {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
        
        //_setToolbarHidden:edge:duration:
        var selName = _PBPopupDecodeBase64String(base64String: sTHedBase64)!
        var selector = NSSelectorFromString(selName)
        originalMethod = class_getInstanceMethod(aClass, selector)
        swizzledMethod = class_getInstanceMethod(aClass, #selector(_sTH(h:e:d:)))
        if let originalMethod = originalMethod, let swizzledMethod = swizzledMethod {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }()
    
    
    /**
     :nodoc:
     */
    @objc public static func nc_swizzle() {
        _ = self.swizzleImplementation
    }
    
    //_setToolbarHidden:edge:duration:
    @objc private func _sTH(h: Bool, e: UInt, d: CGFloat) {
        
        self.view.layoutIfNeeded()
        
        self._sTH(h: h, e: e, d: d)
        let rv = objc_getAssociatedObject(self, &AssociatedKeys.popupBar) as? PBPopupBar
        if (rv != nil) {
            self.bottomBar.isHidden = h
        }
    }
    
    @objc private func pb_pushViewController(_ viewController: UIViewController, animated: Bool) {
        if #available(iOS 12.0, *) {
            _LNPopupSupportFixInsetsForViewController(viewController, false, self.topViewController?.additionalSafeAreaInsets.bottom ?? 0.0)
        }
        self.pb_pushViewController(viewController, animated: animated)
    }
    
    @objc private func pb_setViewControllers(_ viewControllers: [UIViewController], animated: Bool)
    {
        if #available(iOS 12.0, *) {
            for obj in viewControllers {
                _LNPopupSupportFixInsetsForViewController(obj, false, self.topViewController?.additionalSafeAreaInsets.bottom ?? 0.0)
            }
        }
        self.pb_setViewControllers(viewControllers, animated: animated)
    }
}

internal extension UINavigationController {
    @objc internal override func _animateBottomBarToHidden( _ hidden: Bool) {
        var height = self.toolbar.frame.height
        if let tabBarController = self.tabBarController {
            height += tabBarController.defaultFrameForBottomBar().height
        }
        
        let insets = self.insetsForBottomBar()

        if height > 0.0 {
            if hidden == false {
                self.toolbar.frame.origin.y = self.view.bounds.height - height - insets.bottom
            }
            else {
                self.toolbar.frame.origin.y = self.view.bounds.height
            }
            
            if let tabBarController = self.tabBarController {
                tabBarController._animateBottomBarToHidden(hidden)
            }
        }
    }
    
    @objc internal override func _setBottomBarPosition( _ position: CGFloat) {
        let height = self.toolbar.frame.height
        if height > 0.0 {
            self.toolbar.frame.origin.y = position
        }
    }
    
    @objc internal override func insetsForBottomBar() -> UIEdgeInsets {
        if #available(iOS 11.0, *) {
            if let tabBarController = self.tabBarController, tabBarController.isTabBarHiddenDuringTransition == false {
                return tabBarController.insetsForBottomBar()
            }
            return self.view.window?.safeAreaInsets ?? UIEdgeInsets.zero
        } else {
            return UIEdgeInsets.zero
        }
    }
    
    @objc internal override func defaultFrameForBottomBar() -> CGRect {
        var toolBarFrame = self.toolbar.frame
        
        toolBarFrame.origin = CGPoint(x: toolBarFrame.origin.x, y: self.view.bounds.height - (self.isToolbarHidden ? 0.0 : toolBarFrame.size.height))
        
        if let tabBarController = self.tabBarController {
            let tabBarFrame = tabBarController.defaultFrameForBottomBar()
            toolBarFrame.origin.y -= tabBarController.isTabBarHiddenDuringTransition ? 0.0 : tabBarFrame.height
        }
        
        return toolBarFrame
    }
}

public extension UIViewController {
    private static let swizzleImplementation: Void = {
        let instance = UIViewController.self()
        
        let aClass: AnyClass! = object_getClass(instance)
        
        var originalMethod: Method!
        var swizzledMethod: Method!
        
        if ProcessInfo.processInfo.operatingSystemVersion.majorVersion < 11 {
            //_setContentOverlayInsets:
            var selName = _PBPopupDecodeBase64String(base64String: sCoOvBase64)!
            var selector = NSSelectorFromString(selName)
            originalMethod = class_getInstanceMethod(aClass, selector)
            swizzledMethod = class_getInstanceMethod(aClass, #selector(_sCoOvIns(insets:)))
            if let originalMethod = originalMethod, let swizzledMethod = swizzledMethod {
                method_exchangeImplementations(originalMethod, swizzledMethod)
            }
        }
        else {
            //_updateContentOverlayInsetsFromParentIfNecessary
            var selName = _PBPopupDecodeBase64String(base64String: uCOIFPINBase64)!
            var selector = NSSelectorFromString(selName)
            originalMethod = class_getInstanceMethod(aClass, selector)
            swizzledMethod = class_getInstanceMethod(aClass, #selector(_uCOIFPIN))
            if let originalMethod = originalMethod, let swizzledMethod = swizzledMethod {
                method_exchangeImplementations(originalMethod, swizzledMethod)
            }
        }
        
        originalMethod = class_getInstanceMethod(aClass, #selector(addChild(_:)))
        swizzledMethod = class_getInstanceMethod(aClass, #selector(pb_addChild(_ :)))
        if let originalMethod = originalMethod, let swizzledMethod = swizzledMethod {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
        
        originalMethod = class_getInstanceMethod(aClass, #selector(viewDidLayoutSubviews))
        swizzledMethod = class_getInstanceMethod(aClass, #selector(pb_viewDidLayoutSubviews))
        if let originalMethod = originalMethod, let swizzledMethod = swizzledMethod {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
        
        originalMethod = class_getInstanceMethod(aClass, #selector(viewWillTransition(to:with:)))
        swizzledMethod = class_getInstanceMethod(aClass, #selector(pb_viewWillTransition(to:with:)))
        if let originalMethod = originalMethod, let swizzledMethod = swizzledMethod {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }()
    
    /**
     :nodoc:
     */
    @objc public static func vc_swizzle() {
        _ = self.swizzleImplementation
        
        if (ProcessInfo.processInfo.operatingSystemVersion.majorVersion < 10) {
            EasyAnimation.enable()
        }
    }
    
    @objc private func _sCoOvIns(insets: UIEdgeInsets) {
        let rv = objc_getAssociatedObject(self, &AssociatedKeys.popupBar) as? PBPopupBar
        if rv != nil {
            if self.popupController.popupPresentationState != .dismissing {
                var newInsets = insets
                newInsets.bottom += (rv?.frame.size.height)!
                self._sCoOvIns(insets:newInsets)
            }
            else {
                self._sCoOvIns(insets:insets)
            }
        }
        else {
            self._sCoOvIns(insets:insets)
        }
    }
    
    //_updateContentOverlayInsetsFromParentIfNecessary
    @objc private func _uCOIFPIN() {
        self._uCOIFPIN()
    }
    
    internal func pb_popupController() -> PBPopupController! {
        let rv = PBPopupController(containerViewController: self)
        self.popupController = rv
        return rv
    }

    @objc private func pb_addChild(_ viewController: UIViewController) {
        if #available(iOS 12.0, *) {
            _LNPopupSupportFixInsetsForViewController(viewController, false, self.additionalSafeAreaInsets.bottom)
        }
        self.pb_addChild(viewController)
    }
    
    @objc private func pb_viewDidLayoutSubviews() {
        self.pb_viewDidLayoutSubviews()
        if self.popupContentViewController != nil {
            //self is the container
            if self.popupController.popupPresentationState == .presenting || self.popupController.popupPresentationState == .opening || self.popupController.popupPresentationState == .closing { return }
            
            let coordinator = _PBPopupTransitionCoordinator(containerView: self.view)
            
            self.viewWillTransition(to: self.view.frame.size, with: coordinator)
        }
    }
    
    private func viewWillTransitionToSize(_ size: CGSize,  with coordinator: UIViewControllerTransitionCoordinator) {
        if let rv = objc_getAssociatedObject(self, &AssociatedKeys.popupBar) as? PBPopupBar {
            // self is the container
            if self.popupController.popupPresentationState != .dismissing {
                UIView.animate(withDuration: 0.15) {
                    self.popupController.popupBarView.frame = self.popupController.popupPresentationState == .hidden ? self.popupController.popupBarViewFrameForPopupStateHidden() :  self.popupController.popupBarViewFrameForPopupStateClosed()
                }
            }
            if self.popupController.popupPresentationState == .closed {
                self.popupContentView.frame = self.popupController.popupBarViewFrameForPopupStateClosed()
                self.popupContentViewController.view.frame = self.popupContentView.bounds
                self.popupContentViewController.view.frame.size.height = self.view.frame.size.height
            }
            
            rv.setNeedsUpdateConstraints()
            rv.setNeedsLayout()
            rv.layoutIfNeeded()
        }
    }
    
    @objc private func pb_viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.pb_viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: {(_ context: UIViewControllerTransitionCoordinatorContext) -> Void in
            self.viewWillTransitionToSize(size, with: coordinator)
            
        }, completion: {(_ context: UIViewControllerTransitionCoordinatorContext) -> Void in
            // Fix for split view controller layout issue
            if let rv = objc_getAssociatedObject(self, &AssociatedKeys.popupBar) as? PBPopupBar {
                rv.layoutSubviews()
            }
        })
    }
    
    internal func _cleanupPopup() {
        PBLog("_cleanupPopup")
        objc_setAssociatedObject(self, &AssociatedKeys.popupContentViewController, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(self, &AssociatedKeys.popupContentView, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(self, &AssociatedKeys.bottomBar, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(self, &AssociatedKeys.popupBar, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(self, &AssociatedKeys.popupController, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(self, &AssociatedKeys.popupContainerViewController, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_removeAssociatedObjects(self)
    }
}

internal extension UIViewController {
    @objc internal func _animateBottomBarToHidden( _ hidden: Bool) {
        let height = self.popupController.bottomBarHeight
        
        let insets = self.insetsForBottomBar()
        
        if height > 0.0 {
            if hidden == false {
                self.bottomBar.frame.origin.y = self.view.bounds.height - height - insets.bottom
            }
            else {
                self.bottomBar.frame.origin.y = self.view.bounds.height
            }
        }
    }
    
    @objc internal func _setBottomBarPosition( _ position: CGFloat) {
        let height = self.popupController.bottomBarHeight
        if height > 0.0 {
            self.bottomBar.frame.origin.y = position
        }
    }
    
    @objc internal func insetsForBottomBar() -> UIEdgeInsets {
        var insets: UIEdgeInsets = .zero
        if #available(iOS 11.0, *) {
            insets = self.view.window?.safeAreaInsets ?? UIEdgeInsets.zero
            if self.popupController.dataSource?.bottomBarView?(for: self.popupController) != nil {
                if let bottomBarInsets = self.popupController.dataSource?.popupController?(self.popupController, insetsFor: self.bottomBar) {
                    insets = bottomBarInsets
                }
            }
            
        }
        return insets
    }
    
    @objc internal func defaultFrameForBottomBar() -> CGRect {
        var bottomBarFrame = CGRect(x: 0.0, y: self.view.bounds.size.height, width: self.view.bounds.size.width, height: 0.0)
        if let bottomBarView = self.popupController.dataSource?.bottomBarView?(for: self.popupController) {
            if let defaultFrame = self.popupController.dataSource?.popupController?(self.popupController, defaultFrameFor: self.bottomBar) {
                bottomBarFrame = defaultFrame
            }
            else {
                bottomBarFrame = bottomBarView.frame
            }
        }
        bottomBarFrame.origin = CGPoint(x: bottomBarFrame.origin.x, y: self.view.bounds.height - (self.bottomBar.isHidden ? 0.0 : bottomBarFrame.size.height))
        return bottomBarFrame
    }
}

internal class _PBPopupTransitionCoordinator: NSObject, UIViewControllerTransitionCoordinator {
    
    internal var isAnimated: Bool = false
    
    internal var presentationStyle: UIModalPresentationStyle = .none
    
    internal var initiallyInteractive: Bool = false
    
    internal var isInterruptible: Bool = false
    
    internal var isInteractive: Bool = false
    
    internal var isCancelled: Bool = false
    
    internal var transitionDuration: TimeInterval = 0.0
    
    internal var percentComplete: CGFloat = 1.0
    
    internal var completionVelocity: CGFloat = 1.0
    
    internal var completionCurve: UIView.AnimationCurve = .easeInOut
    
    internal func viewController(forKey key: UITransitionContextViewControllerKey) -> UIViewController?
    {
        return nil
    }
    
    internal func view(forKey key: UITransitionContextViewKey) -> UIView?
    {
        return nil
    }
    
    internal var containerView: UIView
    
    internal var targetTransform: CGAffineTransform = .identity
    
    internal init(containerView: UIView)
    {
        self.containerView = containerView
    }
    
    required internal init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal func animate(alongsideTransition animation: ((UIViewControllerTransitionCoordinatorContext) -> Void)?, completion: ((UIViewControllerTransitionCoordinatorContext) -> Void)? = nil) -> Bool
    {
        
        animation?(self)
        
        completion?(self)
        
        return true
    }
    
    internal func animateAlongsideTransition(in view: UIView?, animation: ((UIViewControllerTransitionCoordinatorContext) -> Void)?, completion: ((UIViewControllerTransitionCoordinatorContext) -> Void)? = nil) -> Bool
    {
        return self.animate(alongsideTransition: animation, completion: completion)
    }
    
    internal func notifyWhenInteractionEnds(_ handler: @escaping (UIViewControllerTransitionCoordinatorContext) -> Void)
    {
    }
    
    internal func notifyWhenInteractionChanges(_ handler: @escaping (UIViewControllerTransitionCoordinatorContext) -> Void)
    {
    }
}
