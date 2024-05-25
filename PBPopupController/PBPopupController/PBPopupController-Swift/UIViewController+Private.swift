//
//  UIViewController+Private.swift
//  PBPopupController
//
//  Created by Patrick BODET on 15/04/2018.
//  Copyright © 2018-2024 Patrick BODET. All rights reserved.
//

import Foundation
import UIKit
import ObjectiveC

//_updateContentOverlayInsetsFromParentIfNecessary
private let uCOIFPINBase64 = "X3VwZGF0ZUNvbnRlbnRPdmVybGF5SW5zZXRzRnJvbVBhcmVudElmTmVjZXNzYXJ5"
//_viewSafeAreaInsetsFromScene
private let vSAIFSBase64 = "X3ZpZXdTYWZlQXJlYUluc2V0c0Zyb21TY2VuZQ=="
//_hideBarWithTransition:isExplicit:
private let hBWTiEBase64 = "X2hpZGVCYXJXaXRoVHJhbnNpdGlvbjppc0V4cGxpY2l0Og=="
//_hideBarWithTransition:isExplicit:duration:
private let hBWTiEDBase64 = "X2hpZGVCYXJXaXRoVHJhbnNpdGlvbjppc0V4cGxpY2l0OmR1cmF0aW9uOg=="
//_showBarWithTransition:isExplicit:
private let sBWTiEBase64 = "X3Nob3dCYXJXaXRoVHJhbnNpdGlvbjppc0V4cGxpY2l0Og=="
//_showBarWithTransition:isExplicit:duration:
private let sBWTiEDBase64 = "X3Nob3dCYXJXaXRoVHJhbnNpdGlvbjppc0V4cGxpY2l0OmR1cmF0aW9uOg=="
//_setToolbarHidden:edge:duration:
private let sTHedBase64 = "X3NldFRvb2xiYXJIaWRkZW46ZWRnZTpkdXJhdGlvbjo="
//hideBarWithTransition:
private let hBWTBase64 = "aGlkZUJhcldpdGhUcmFuc2l0aW9uOg=="
//showBarWithTransition:
private let sBWTBase64 = "c2hvd0JhcldpdGhUcmFuc2l0aW9uOg=="

public extension UITabBarController
{
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
        var selName = _PBPopupDecodeBase64String(base64String: hBWTiEDBase64)!
        var selector = NSSelectorFromString(selName)
        originalMethod = class_getInstanceMethod(aClass, selector)
        swizzledMethod = class_getInstanceMethod(aClass, #selector(_hBWT(t:iE:d:)))
        if let originalMethod = originalMethod, let swizzledMethod = swizzledMethod {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
        
        //_showBarWithTransition:isExplicit:
        /*
        selName = _PBPopupDecodeBase64String(base64String: sBWTiEBase64)!
        selector = NSSelectorFromString(selName)
        originalMethod = class_getInstanceMethod(aClass, selector)
        swizzledMethod = class_getInstanceMethod(aClass, #selector(_sBWT(t:iE:)))
        if let originalMethod = originalMethod, let swizzledMethod = swizzledMethod {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
        */
        
        //_showBarWithTransition:isExplicit:duration:
        selName = _PBPopupDecodeBase64String(base64String: sBWTiEDBase64)!
        selector = NSSelectorFromString(selName)
        originalMethod = class_getInstanceMethod(aClass, selector)
        swizzledMethod = class_getInstanceMethod(aClass, #selector(_sBWT(t:iE:d:)))
        if let originalMethod = originalMethod, let swizzledMethod = swizzledMethod {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }()
    
    /**
     :nodoc:
     */
    @objc static func tbc_swizzle()
    {
        _ = self.swizzleImplementation
    }
    
    //_hideBarWithTransition:isExplicit:duration:
    @objc private func _hBWT(t: Int, iE: Bool, d: TimeInterval)
    {
        self.isTabBarHiddenDuringTransition = true
        
        self._hBWT(t: t, iE: iE, d: d)
        
        if (t > 0) {
            if let rv = UITabBarController.getAssociatedPopupBarFor(self) {
                if self.popupController.popupPresentationState != .hidden {
                    rv.applyGroupingIdentifier(fromBottomBar: false)
                    self.bottomBar.isHidden = true
                    
                    if self.popupBarIsHidden == false {
                        if rv.isFloating {
                            rv.backgroundView.alpha = 0.0
                            if let transitionView = rv.transitionBackgroundView {
                                transitionView.effect = rv.backgroundView.effect
                                if rv.enablePopupBarColorsDebug {
                                    transitionView.backgroundColor = .yellow
                                    transitionView.effect = nil
                                }
                                transitionView.frame = self.popupController.popupBarView.frame
                                self.view.addSubview(transitionView)
                                transitionView.isHidden = true
                            }
                        }
                        self.selectedViewController?.transitionCoordinator?.animate(alongsideTransition: { context in
                            self.popupController.popupBarView.frame = self.popupController.popupBarViewFrameForPopupStateClosed()
                            self.popupController.popupBarView.layoutIfNeeded()
                        }, completion: { context in
                            //
                        })
                    }
                }
            }
        }
    }
    
    //_showBarWithTransition:isExplicit:duration:
    @objc private func _sBWT(t: Int, iE: Bool, d: TimeInterval)
    {
        self.isTabBarHiddenDuringTransition = false

        self._sBWT(t: t, iE: iE, d: d)

        if (t > 0) {
            if let rv = UITabBarController.getAssociatedPopupBarFor(self) {
                if let vc = self.popupController.containerViewController {
                    if self.popupController.popupPresentationState != .hidden || vc.popupBarIsHidden {
                        rv.applyGroupingIdentifier(fromBottomBar: false)
                        if rv.isFloating {
                            if let transitionView = rv.transitionBackgroundView {
                                transitionView.frame.size.width = .zero
                                transitionView.layoutIfNeeded()
                                transitionView.isHidden = false
                            }
                        }
                        self.popupController.popupBarView.alpha = 1
                        self.selectedViewController?.transitionCoordinator?.animate(alongsideTransition: { context in
                            self.popupController.popupBarView.frame = self.popupController.popupBarViewFrameForPopupStateClosed()
                            if rv.isFloating {
                                if let transitionView = rv.transitionBackgroundView {
                                    transitionView.frame = self.popupController.popupBarView.frame
                                    transitionView.layoutIfNeeded()
                                }
                            }
                            self.popupController.popupPresentationState = .closed
                            vc.popupBarIsHidden = false
                            if self.popupBarWasHidden {
                                self.popupController.fixInsetsForContainerIfNeeded(addInsets: true, layout: false)
                            }
                            self.popupController.popupBarView.layoutIfNeeded()
                        }, completion: { (_ context) in
                            if context.isCancelled {
                                self.isTabBarHiddenDuringTransition = true
                                
                                if rv.isFloating {
                                    if let transitionView = rv.transitionBackgroundView {
                                        transitionView.isHidden = true
                                    }
                                }
                                if !self.popupBarWasHidden {
                                    self.popupController.popupBarView.frame = self.popupController.popupBarViewFrameForPopupStateClosed()
                                }
                                
                                if self.popupBarWasHidden {
                                    self.popupController.popupBarView.alpha = 0
                                    self.popupController.popupPresentationState = .hidden
                                    vc.popupBarIsHidden = true
                                    self.popupController.fixInsetsForContainerIfNeeded(addInsets: false, layout: true)
                                }
                                self.popupController.popupBarView.layoutIfNeeded()
                            }
                            else {
                                if rv.isFloating {
                                    if let transitionView = rv.transitionBackgroundView {
                                        rv.backgroundView.alpha = 1.0
                                        transitionView.isHidden = true
                                        transitionView.removeFromSuperview()
                                    }
                                }
                            }
                            rv.applyGroupingIdentifier(fromBottomBar: context.isCancelled ? false : true)
                            self.bottomBar.isHidden = context.isCancelled ? true : false
                        })
                    }
                }
            }
        }
    }
    
    @objc private func pb_setViewControllers(_ viewControllers: [UIViewController], animated: Bool)
    {
        self.pb_setViewControllers(viewControllers, animated: animated)
        
        for obj in viewControllers {
            let additionalInsets = self.popupAdditionalSafeAreaInsets
            if obj.popupAdditionalSafeAreaInsets == .zero {
                PBPopupFixInsetsForViewController(self, false, additionalInsets)
            }
        }
    }
}

internal extension UITabBarController
{
    @objc override func _animateBottomBarToHidden( _ hidden: Bool)
    {
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
    
    @objc override func _setBottomBarPosition( _ position: CGFloat)
    {
        let height = self.tabBar.frame.height
        if height > 0.0 {
            self.tabBar.frame.origin.y = position
        }
    }
    
    @objc override func insetsForBottomBar() -> UIEdgeInsets
    {
        if let bottomBarInsets = self.popupController.dataSource?.popupController?(self.popupController, insetsFor: self.bottomBar) {
            return bottomBarInsets
        }
        if let dropShadowView = self.popupController.dropShadowViewFor(self.view) {
            if dropShadowView.frame.minX > 0 {
                return UIEdgeInsets.zero
            }
        }
        return self.tabBar.isHidden == false ? UIEdgeInsets.zero : self.view.window?.safeAreaInsets ?? UIEdgeInsets.zero
    }
    
    @objc override func defaultFrameForBottomBar() -> CGRect
    {
        var bottomBarFrame = self.tabBar.frame
        let bottomBarSizeThatFits = self.tabBar.sizeThatFits(CGSize.zero)
        
        bottomBarFrame.size.height = max(bottomBarFrame.size.height, bottomBarSizeThatFits.height)
        
        bottomBarFrame.origin = CGPoint(x: 0, y: self.view.bounds.size.height - (self.isTabBarHiddenDuringTransition ? 0.0 : bottomBarFrame.size.height))
        
        return bottomBarFrame
    }
    
    @objc override func configureScrollEdgeAppearanceForBottomBar() {
#if targetEnvironment(macCatalyst)
        return
#else
        if #available(iOS 15.0, *) {
            if self.popupBar.inheritsVisualStyleFromBottomBar == false {
                return
            }
            
            if self.popupController.popupPresentationState == .presenting {
                self.tabBar.scrollEdgeAppearance = self.tabBar.standardAppearance
            }
        }
#endif
    }
    
    @objc override func configurePopupBarFromBottomBar()
    {
        self.popupBar.effectGroupingIdentifier = self.tabBar._effectGroupingIdentifierIfAvailable
        self.popupBar.applyGroupingIdentifier(fromBottomBar: true)
        
        let appearance = UITabBarAppearance()
        self.popupBar.shadowColor = appearance.shadowColor
        
        let bottomBarAppearance = self.tabBar.standardAppearance
        
        if self.bottomBarAppearance == nil {
            self.bottomBarAppearance = bottomBarAppearance.copy()
        }
        
        self.popupBar.shadowColor = self.bottomBarAppearance.shadowColor
        
        bottomBarAppearance.shadowColor = self.bottomBarAppearance.shadowColor
        if self.popupBar.isFloating, self.popupController.popupPresentationState != .hidden {
            if self.popupController.popupPresentationState != .dismissing {
                bottomBarAppearance.shadowColor = .clear
            }
        }
        
        self.tabBar.standardAppearance = bottomBarAppearance
        if #available(iOS 15.0, *) {
            self.tabBar.scrollEdgeAppearance = bottomBarAppearance
        }
        
        if self.popupBar.inheritsVisualStyleFromBottomBar == false {
            return
        }
        self.popupBar.backgroundEffect = self.bottomBarAppearance.backgroundEffect
        self.popupBar.barStyle = self.tabBar.barStyle
        self.popupBar.tintColor = self.tabBar.tintColor
        self.popupBar.isTranslucent = self.tabBar.isTranslucent
        self.popupBar.backgroundColor = self.bottomBarAppearance.backgroundColor
    }
}

public extension UINavigationController
{
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
        
        originalMethod = class_getInstanceMethod(aClass, #selector(popViewController(animated:)))
        swizzledMethod = class_getInstanceMethod(aClass, #selector(pb_popViewController(animated:)))
        if let originalMethod = originalMethod, let swizzledMethod = swizzledMethod {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
        
        originalMethod = class_getInstanceMethod(aClass, #selector(popToViewController(_ :animated:)))
        swizzledMethod = class_getInstanceMethod(aClass, #selector(pb_popToViewController(_ :animated:)))
        if let originalMethod = originalMethod, let swizzledMethod = swizzledMethod {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
        
        originalMethod = class_getInstanceMethod(aClass, #selector(popToRootViewController(animated:)))
        swizzledMethod = class_getInstanceMethod(aClass, #selector(pb_popToRootViewController(animated:)))
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
        
        originalMethod = class_getInstanceMethod(aClass, #selector(viewDidLayoutSubviews))
        swizzledMethod = class_getInstanceMethod(aClass, #selector(pb_ncDidLayoutSubviews))
        if let originalMethod = originalMethod, let swizzledMethod = swizzledMethod {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }()
    
    /**
     :nodoc:
     */
    @objc static func nc_swizzle()
    {
        _ = self.swizzleImplementation
    }
    
    //_setToolbarHidden:edge:duration:
    @objc private func _sTH(h: Bool, e: UInt, d: CGFloat)
    {
        if let rv = UINavigationController.getAssociatedPopupBarFor(self) {
            if self.popupController.popupPresentationState != .hidden {
                if self.popupBarIsHidden == true {
                    self.popupController.popupBarView.frame = self.popupController.popupBarViewFrameForPopupStateHidden()
                }
                else {
                    self.popupController.popupBarView.frame = self.popupController.popupBarViewFrameForPopupStateClosed()
                }
                self._sTH(h: h, e: e, d: d)
                self.bottomBar.isHidden = h
                if rv.isFloating {
                    rv.backgroundView.alpha = 0.0
                    if let transitionView = rv.transitionBackgroundView {
                        if self.bottomBar.isHidden {
                            transitionView.effect = rv.backgroundView.effect
                            if rv.enablePopupBarColorsDebug {
                                transitionView.backgroundColor = .yellow
                                transitionView.effect = nil
                            }
                            transitionView.frame = self.popupController.popupBarView.frame
                            self.view.addSubview(transitionView)
                            transitionView.isHidden = true
                        }
                        else {
                            transitionView.frame.size.width = .zero
                            transitionView.layoutIfNeeded()
                            transitionView.isHidden = false
                        }
                    }
                }
                if let coordinator = self.transitionCoordinator {
                    coordinator.animate(alongsideTransition: { (_ context) in
                        self.popupController.popupBarView.frame = self.popupController.popupBarViewFrameForPopupStateClosed()
                        if rv.isFloating {
                            if !self.bottomBar.isHidden {
                                if let transitionView = rv.transitionBackgroundView {
                                    transitionView.frame = self.popupController.popupBarView.frame
                                    transitionView.layoutIfNeeded()
                                }
                            }
                        }
                        if self.popupBarWasHidden {
                            self.popupController.fixInsetsForContainerIfNeeded(addInsets: true, layout: false)
                        }
                        self.popupController.popupBarView.layoutIfNeeded()
                    }) { (_ context) in
                        if context.isCancelled {
                            if self.popupBarWasHidden {
                                self.popupBarIsHidden = true
                                self.popupController.popupBarView.frame = self.popupController.popupBarViewFrameForPopupStateHidden()
                                if rv.isFloating {
                                    rv.backgroundView.alpha = 0.0
                                    if let transitionView = rv.transitionBackgroundView {
                                        transitionView.isHidden = true
                                    }
                                }
                                self.popupController.fixInsetsForContainerIfNeeded(addInsets: false, layout: false)
                            }
                        }
                        else {
                            if rv.isFloating {
                                if let transitionView = rv.transitionBackgroundView {
                                    if !self.bottomBar.isHidden {
                                        rv.backgroundView.alpha = 1.0
                                        transitionView.isHidden = true
                                        transitionView.removeFromSuperview()
                                    }
                                }
                            }
                        }
                        self.bottomBar.isHidden = context.isCancelled ? true : false
                    }
                }
                else {
                    UIView.animate(withDuration: d) {
                        self.popupController.popupBarView.frame = self.popupController.popupBarViewFrameForPopupStateClosed()
                        if self.popupBarWasHidden {
                            self.popupController.fixInsetsForContainerIfNeeded(addInsets: true, layout: false)
                        }
                        self.popupController.popupBarView.layoutIfNeeded()
                    }
                }
            }
            else {
                self._sTH(h: h, e: e, d: d)
                self.bottomBar.isHidden = h
                self.popupController.popupBarView.layoutIfNeeded()
            }
        }
        else {
            self._sTH(h: h, e: e, d: d)
        }
    }
    
    @objc private func pb_ncDidLayoutSubviews()
    {
        if self.responds(to: #selector(pb_ncDidLayoutSubviews)) {
            self.pb_ncDidLayoutSubviews()
            if let rv = UINavigationController.getAssociatedPopupBarFor(self) {
                var position: CGFloat = 0
                if let presentation = self.toolbar.layer.presentation() {
                    position = presentation.position.x
                }
                self.popupController.containerViewController.popupBar.backgroundView.alpha = rv.isFloating ? (self.toolbar.isHidden || position < 0 ? 0.0 : 1.0) : 1.0
                if rv.isFloating {
                    self.popupController?.popupBarView?.superview?.bringSubviewToFront(self.popupController.popupBarView)
                }
                else {
                    self.popupController?.popupBarView?.superview?.insertSubview(self.popupController.popupBarView, belowSubview: bottomBar)
                }
            }
        }
    }
    
    @objc private func pb_pushViewController(_ viewController: UIViewController, animated: Bool)
    {
        if let popupController = self.popupControllerFor(self) {
            if let vc = popupController.containerViewController {
                if self.popupBarFor(vc) != nil, popupController.popupPresentationState == .closed {
                    vc.popupBarWasHidden = false
                    if viewController.hidesPopupBarWhenPushed || vc.popupBarIsHidden {
                        viewController.hidesPopupBarWhenPushed = true
                        vc.popupBarIsHidden = true
                        vc.hidePopupBar(animated: false, completion: nil)
                    }
                }
            }
        }
        if let rv = UINavigationController.getAssociatedPopupBarFor(self), !rv.isHidden {
            let additionalInsets = UIEdgeInsets(top: 0, left: 0, bottom: self.topViewController?.additionalSafeAreaInsets.bottom ?? 0.0, right: 0)
            if viewController.popupAdditionalSafeAreaInsets == .zero {
                PBPopupFixInsetsForViewController(viewController, false, additionalInsets)
            }
        }
        self.pb_pushViewController(viewController, animated: animated)
    }
    
    @objc private func pb_popViewController(animated: Bool) -> UIViewController?
    {
        if let top = self.topViewController, top.hidesPopupBarWhenPushed {
            if let popupController = self.popupControllerFor(self) {
                if let vc = popupController.containerViewController {
                    if self.popupBarFor(vc) != nil, vc.popupBarIsHidden == true {
                        let back = self.viewControllers[self.viewControllers.count - 2] as UIViewController
                        if back.hidesPopupBarWhenPushed == false {
                            vc.popupBarWasHidden = true
                            if let nc = vc as? UINavigationController, nc.isToolbarHidden {
                                if let top = self.pb_popViewController(animated: animated), top.transitionCoordinator != nil {
                                    self.startInteractivePopupBarTransition(fromViewController: top)
                                    return top
                                }
                            }
                        }
                    }
                }
            }
        }
        return self.pb_popViewController(animated: animated)
    }
    
    @objc private func pb_popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]?
    {
        if let top = self.topViewController, top.hidesPopupBarWhenPushed {
            if let popupController = self.popupControllerFor(self) {
                if let vc = popupController.containerViewController {
                    if self.popupBarFor(vc) != nil, vc.popupBarIsHidden == true {
                        if viewController.hidesPopupBarWhenPushed == false {
                            vc.popupBarWasHidden = true
                            if let nc = vc as? UINavigationController, nc.isToolbarHidden {
                                if let viewControllers = self.pb_popToViewController(viewController, animated: animated), vc.transitionCoordinator != nil {
                                    self.startInteractivePopupBarTransition(fromViewController: top)
                                    return viewControllers
                                }
                            }
                        }
                    }
                }
            }
        }
        return self.pb_popToViewController(viewController, animated: animated)
    }
    
    @objc private func pb_popToRootViewController(animated: Bool) -> [UIViewController]?
    {
        if let top = self.topViewController, top.hidesPopupBarWhenPushed {
            if let popupController = self.popupControllerFor(self) {
                if let vc = popupController.containerViewController {
                    if self.popupBarFor(vc) != nil, vc.popupBarIsHidden == true {
                        let back = self.viewControllers[0] as UIViewController
                        if back.hidesPopupBarWhenPushed == false {
                            vc.popupBarWasHidden = true
                            if let nc = vc as? UINavigationController, nc.isToolbarHidden {
                                if let viewControllers = self.pb_popToRootViewController(animated: animated), vc.transitionCoordinator != nil {
                                    self.startInteractivePopupBarTransition(fromViewController: top)
                                    return viewControllers
                                }
                            }
                        }
                    }
                }
            }
        }
        return self.pb_popToRootViewController(animated: animated)
    }
    
    @objc private func pb_setViewControllers(_ viewControllers: [UIViewController], animated: Bool)
    {
        self.pb_setViewControllers(viewControllers, animated: animated)
        for obj in viewControllers {
            let additionalInsets = self.popupAdditionalSafeAreaInsets
            if obj.popupAdditionalSafeAreaInsets == .zero {
                PBPopupFixInsetsForViewController(self, false, additionalInsets)
            }
        }
    }
    
    private func startInteractivePopupBarTransition(fromViewController: UIViewController)
    {
        guard let popupController = self.popupControllerFor(self), let vc = popupController.containerViewController else {
            return
        }
        popupController.popupBarView.alpha = 1
        if let coordinator = fromViewController.transitionCoordinator {
            coordinator.animate { context in
                popupController.popupBarView.frame = popupController.popupBarViewFrameForPopupStateClosed()
                self.popupController.popupPresentationState = .closed
                vc.popupBarIsHidden = false
                if vc.popupBarWasHidden {
                    popupController.fixInsetsForContainerIfNeeded(addInsets: true, layout: false)
                }
            } completion: { context in
                if context.isCancelled {
                    if vc.popupBarWasHidden {
                        popupController.popupBarView.alpha = 0.0
                        self.popupController.popupPresentationState = .hidden
                        vc.popupBarIsHidden = true
                        popupController.popupBarView.frame = popupController.popupBarViewFrameForPopupStateHidden()
                        popupController.fixInsetsForContainerIfNeeded(addInsets: false, layout: false)
                    }
                }
            }
        }
    }
    
    private func popupControllerFor(_ controller: UIViewController) -> PBPopupController?
    {
        if let rv = UINavigationController.getAssociatedPopupControllerFor(controller) {
            return rv
        }
        if  controller.parent == nil {
            return nil
        }
        return popupControllerFor(controller.parent!)
    }
    
    private func popupBarFor(_ controller: UIViewController) -> PBPopupBar?
    {
        if let rv = UINavigationController.getAssociatedPopupBarFor(controller) {
            return rv
        }
        return nil
    }
}

internal extension UINavigationController
{
    @objc override func _animateBottomBarToHidden( _ hidden: Bool)
    {
        var height = self.toolbar.frame.height
        if let tabBarController = self.tabBarController {
            height += tabBarController.defaultFrameForBottomBar().height
        }
        
        if height > 0.0 {
            if hidden == false {
                self.toolbar.transform = .identity
            }
            else {
                let fromY = self.toolbar.frame.minY
                let toY = self.view.bounds.height
                self.toolbar.transform = self.toolbar.transform.translatedBy(x: 0, y: toY - fromY)
            }
            if let tabBarController = self.tabBarController {
                tabBarController._animateBottomBarToHidden(hidden)
            }
        }
    }
    
    @objc override func _setBottomBarPosition( _ position: CGFloat)
    {
        let height = self.toolbar.frame.height
        if height > 0.0 {
            self.toolbar.frame.origin.y = position
        }
    }
    
    @objc override func insetsForBottomBar() -> UIEdgeInsets
    {
        if let tabBarController = self.tabBarController, tabBarController.isTabBarHiddenDuringTransition == false {
            return tabBarController.insetsForBottomBar()
        }
        if let dropShadowView = self.popupController.dropShadowViewFor(self.view) {
            if dropShadowView.frame.minX > 0 {
                return UIEdgeInsets.zero
            }
        }
        return self.view.window?.safeAreaInsets ?? UIEdgeInsets.zero
    }
    
    @objc override func defaultFrameForBottomBar() -> CGRect
    {
        var toolBarFrame = self.toolbar.frame

        toolBarFrame.origin = CGPoint(x: 0, y: self.view.bounds.height - (self.isToolbarHidden ? 0.0 : toolBarFrame.size.height))
        toolBarFrame.size.height = self.isToolbarHidden ? 0.0 : toolBarFrame.size.height
        toolBarFrame.size.width = self.navigationBar.frame.width
        
        if let tabBarController = self.tabBarController {
            let tabBarFrame = tabBarController.defaultFrameForBottomBar()
            toolBarFrame.origin.y -= tabBarController.isTabBarHiddenDuringTransition ? 0.0 : tabBarFrame.height
        }
        
        return toolBarFrame
    }
    
    @objc override func configureScrollEdgeAppearanceForBottomBar()
    {
#if targetEnvironment(macCatalyst)
#else
        if #available(iOS 15.0, *) {
            if self.popupBar.inheritsVisualStyleFromBottomBar == false {
                return
            }
            
            if self.popupController.popupPresentationState == .presenting {
                self.toolbar.scrollEdgeAppearance = self.toolbar.standardAppearance
                self.toolbar.compactScrollEdgeAppearance = self.toolbar.standardAppearance
            }
        }
#endif
    }
    
    @objc override func configurePopupBarFromBottomBar()
    {
        self.popupBar.effectGroupingIdentifier = self.toolbar._effectGroupingIdentifierIfAvailable
        self.popupBar.applyGroupingIdentifier(fromBottomBar: true)
        
        let appearance = UIToolbarAppearance()
        self.popupBar.shadowColor = appearance.shadowColor

        let bottomBarAppearance = self.toolbar.standardAppearance

        if self.bottomBarAppearance == nil {
            self.bottomBarAppearance = bottomBarAppearance.copy()
        }
        
        self.popupBar.shadowColor = self.bottomBarAppearance.shadowColor
        
        bottomBarAppearance.shadowColor = self.bottomBarAppearance.shadowColor
        if self.popupBar.isFloating, self.popupController.popupPresentationState != .hidden {
            if self.popupController.popupPresentationState != .dismissing {
                bottomBarAppearance.shadowColor = .clear
            }
        }
        
        self.toolbar.standardAppearance = bottomBarAppearance
        self.toolbar.compactAppearance = bottomBarAppearance
        if #available(iOS 15.0, *) {
            self.toolbar.scrollEdgeAppearance = bottomBarAppearance
            self.toolbar.compactScrollEdgeAppearance = bottomBarAppearance
        }

        if self.popupBar.inheritsVisualStyleFromBottomBar == false {
            return
        }
        self.popupBar.backgroundEffect = self.bottomBarAppearance.backgroundEffect
        self.popupBar.barStyle = self.navigationBar.barStyle
        self.popupBar.tintColor = self.navigationBar.tintColor
        if let svc = self.splitViewController, let nc = svc.viewControllers[0] as? UINavigationController {
            self.popupBar.tintColor = nc.navigationBar.tintColor
        }
        self.popupBar.isTranslucent = self.navigationBar.isTranslucent
        self.popupBar.backgroundColor = self.bottomBarAppearance.backgroundColor
    }
}

public extension UISplitViewController
{
    private static let swizzleImplementation: Void = {
        let instance = UISplitViewController.self()
        
        let aClass: AnyClass! = object_getClass(instance)
        
        var originalMethod: Method!
        var swizzledMethod: Method!
        
        originalMethod = class_getInstanceMethod(aClass, #selector(viewDidLayoutSubviews))
        swizzledMethod = class_getInstanceMethod(aClass, #selector(pb_svcDidLayoutSubviews))
        if let originalMethod = originalMethod, let swizzledMethod = swizzledMethod {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }()
    
    /**
     :nodoc:
     */
    @objc static func svc_swizzle()
    {
        _ = self.swizzleImplementation
    }
    
    @objc private func pb_svcDidLayoutSubviews()
    {
        self.pb_svcDidLayoutSubviews()
        if let rv = UISplitViewController.getAssociatedPopupBarFor(self) {
            self.popupController.containerViewController.popupBar.backgroundView.alpha = rv.isFloating ? 0.0 : 1.0
        }
    }
}
    
public extension UIViewController
{
    private static let swizzleImplementation: Void = {
        let instance = UIViewController.self()
        
        let aClass: AnyClass! = object_getClass(instance)
        
        var originalMethod: Method!
        var swizzledMethod: Method!
        
#if !targetEnvironment(macCatalyst)
        //_updateContentOverlayInsetsFromParentIfNecessary
        var selName = _PBPopupDecodeBase64String(base64String: uCOIFPINBase64)!
        var selector = NSSelectorFromString(selName)
        originalMethod = class_getInstanceMethod(aClass, selector)
        swizzledMethod = class_getInstanceMethod(aClass, #selector(_uCOIFPIN))
        if let originalMethod = originalMethod, let swizzledMethod = swizzledMethod {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }

        //_viewSafeAreaInsetsFromScene
        selName = _PBPopupDecodeBase64String(base64String: vSAIFSBase64)!
        selector = NSSelectorFromString(selName)
        originalMethod = class_getInstanceMethod(aClass, selector)
        swizzledMethod = class_getInstanceMethod(aClass, #selector(_vSAIFS))
        if let originalMethod = originalMethod, let swizzledMethod = swizzledMethod {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
#else
        var selName = _PBPopupDecodeBase64String(base64String: uCOIFPINBase64)!
        var selector = NSSelectorFromString(selName)
        originalMethod = class_getInstanceMethod(aClass, selector)
        swizzledMethod = class_getInstanceMethod(aClass, #selector(_uCOIFPIN))
        if let originalMethod = originalMethod, let swizzledMethod = swizzledMethod {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
#endif
        
        originalMethod = class_getInstanceMethod(aClass, #selector(addChild(_:)))
        swizzledMethod = class_getInstanceMethod(aClass, #selector(pb_addChild(_ :)))
        if let originalMethod = originalMethod, let swizzledMethod = swizzledMethod {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
        
        originalMethod = class_getInstanceMethod(aClass, #selector(viewWillTransition(to:with:)))
        swizzledMethod = class_getInstanceMethod(aClass, #selector(pb_viewWillTransition(to:with:)))
        if let originalMethod = originalMethod, let swizzledMethod = swizzledMethod {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
        
        originalMethod = class_getInstanceMethod(aClass, #selector(willTransition(to:with:)))
        swizzledMethod = class_getInstanceMethod(aClass, #selector(pb_willTransition(to:with:)))
        if let originalMethod = originalMethod, let swizzledMethod = swizzledMethod {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
        
        originalMethod = class_getInstanceMethod(aClass, #selector(viewDidLayoutSubviews))
        swizzledMethod = class_getInstanceMethod(aClass, #selector(pb_viewDidLayoutSubviews))
        if let originalMethod = originalMethod, let swizzledMethod = swizzledMethod {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }()
    
    /**
     :nodoc:
     */
    @objc static func vc_swizzle()
    {
        _ = self.swizzleImplementation
    }
    
    //_updateContentOverlayInsetsFromParentIfNecessary
    @objc private func _uCOIFPIN()
    {
        self._uCOIFPIN()
    }
    
    //_viewSafeAreaInsetsFromScene
    @objc private func _vSAIFS() -> UIEdgeInsets
    {
        /// Find the popup content view safe area insets
        if let vc = self.popupContainerViewController, let popupContentView = vc.popupContentView {
            if var insets = popupContentView.superview?.safeAreaInsets {
                insets.top = 0
                return insets
            }
        }
        let insets = self._vSAIFS()
        return insets
    }
    
    internal func pb_popupController() -> PBPopupController!
    {
        let rv = PBPopupController(containerViewController: self)
        self.popupController = rv
        return rv
    }
    
    @objc private func pb_addChild(_ viewController: UIViewController)
    {
        self.pb_addChild(viewController)
        
        if self.additionalSafeAreaInsetsBottomForContainer > 0 {
            let additionalInsets = UIEdgeInsets(top: 0, left: 0, bottom: self.additionalSafeAreaInsetsBottomForContainer, right: 0)
            PBPopupFixInsetsForViewController(self, false, additionalInsets)
        }
        
        if let svc = self as? UISplitViewController {
            if let vc1 = svc.children.first, let rv = UIViewController.getAssociatedPopupBarFor(vc1), !rv.isHidden {
                var additionalInsets: UIEdgeInsets
                if let nc = vc1 as? UINavigationController {
                    additionalInsets = UIEdgeInsets(top: 0, left: 0, bottom: -nc.topViewController!.additionalSafeAreaInsets.bottom, right: 0)
                }
                else {
                    additionalInsets = UIEdgeInsets(top: 0, left: 0, bottom: -viewController.additionalSafeAreaInsets.bottom, right: 0)
                }
                PBPopupFixInsetsForViewController(viewController, false, additionalInsets)
            }
            else {
                if let vc1 = svc.children.first {
                    let additionalInsets = UIEdgeInsets(top: 0, left: 0, bottom: vc1.additionalSafeAreaInsets.bottom, right: 0)
                    PBPopupFixInsetsForViewController(viewController, false, additionalInsets)
                }
            }
        }
    }
    
    private func viewWillTransitionToSize(_ size: CGSize,  with coordinator: UIViewControllerTransitionCoordinator)
    {
        if self.popupController.popupPresentationState != .dismissing {
            self.popupController.popupBarView.frame = self.popupController.popupPresentationState == .hidden ? self.popupController.popupBarViewFrameForPopupStateHidden() :  self.popupController.popupBarViewFrameForPopupStateClosed()
        }
        
        if let popupContentViewController = self.popupContentViewController {
            popupContentViewController.view.setNeedsUpdateConstraints()
            popupContentViewController.view.setNeedsLayout()
            popupContentViewController.view.layoutIfNeeded()
        }
    }
    
    @objc private func pb_viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator)
    {
        self.pb_viewWillTransition(to: size, with: coordinator)

        if let popupContentViewController = self.popupContentViewController {
            popupContentViewController.viewWillTransition(to: size, with: coordinator)
        }
        if let rv = UIViewController.getAssociatedPopupBarFor(self) {
            if let customPopupBarViewController = rv.customPopupBarViewController {
                customPopupBarViewController.viewWillTransition(to: size, with: coordinator)
            }
            coordinator.animate(alongsideTransition: {(_ context: UIViewControllerTransitionCoordinatorContext) -> Void in
                self.viewWillTransitionToSize(size, with: coordinator)
            }, completion: {(_ context: UIViewControllerTransitionCoordinatorContext) -> Void in
                self.viewWillTransitionToSize(size, with: coordinator)
                rv.setNeedsUpdateConstraints()
                rv.setNeedsLayout()
                rv.layoutIfNeeded()
            })
        }
    }
    
    @objc private func pb_willTransition(to traitCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator)
    {
        self.pb_willTransition(to: traitCollection, with: coordinator)
        
        if let popupContentViewController = self.popupContentViewController {
            popupContentViewController.willTransition(to: traitCollection, with: coordinator)
        }
        if let rv = UIViewController.getAssociatedPopupBarFor(self) {
            if let customPopupBarViewController = rv.customPopupBarViewController {
                customPopupBarViewController.willTransition(to: traitCollection, with: coordinator)
            }
        }
    }
    
    @objc private func pb_viewDidLayoutSubviews()
    {
        self.pb_viewDidLayoutSubviews()
        if let rv = UIViewController.getAssociatedPopupBarFor(self) {
            if !(self is UITabBarController) && !(self is UINavigationController) {
                self.popupController.containerViewController.popupBar.backgroundView.alpha = rv.isFloating ? 0.0 : 1.0
            }
            if rv.isFloating {
                self.popupController?.popupBarView?.superview?.bringSubviewToFront(self.popupController.popupBarView)
            }
            else {
                self.popupController?.popupBarView?.superview?.insertSubview(self.popupController.popupBarView, belowSubview: bottomBar)
            }
        }
    }
    
    internal func _cleanupPopup()
    {
        PBLog("_cleanupPopup")
        withUnsafePointer(to: &AssociatedKeys.enablePopupBarColorsDebug) {
            objc_setAssociatedObject(self, $0, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        withUnsafePointer(to: &AssociatedKeys.usePopupBarSmoothGradient) {
            objc_setAssociatedObject(self, $0, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        withUnsafePointer(to: &AssociatedKeys.usePopupBarLegacyShadow) {
            objc_setAssociatedObject(self, $0, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        withUnsafePointer(to: &AssociatedKeys.isTabBarHiddenDuringTransition) {
            objc_setAssociatedObject(self, $0, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        withUnsafePointer(to: &AssociatedKeys.hidesPopupBarWhenPushed) {
            objc_setAssociatedObject(self, $0, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        withUnsafePointer(to: &AssociatedKeys.popupBarIsHidden) {
            objc_setAssociatedObject(self, $0, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        withUnsafePointer(to: &AssociatedKeys.popupBarWasHidden) {
            objc_setAssociatedObject(self, $0, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        withUnsafePointer(to: &AssociatedKeys.additionalSafeAreaInsetsBottomForContainer) {
            objc_setAssociatedObject(self, $0, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        withUnsafePointer(to: &AssociatedKeys.popupAdditionalSafeAreaInsets) {
            objc_setAssociatedObject(self, $0, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        withUnsafePointer(to: &AssociatedKeys.popupContentViewController) {
            objc_setAssociatedObject(self, $0, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        withUnsafePointer(to: &AssociatedKeys.popupContentView) {
            objc_setAssociatedObject(self, $0, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        withUnsafePointer(to: &AssociatedKeys.popupBar) {
            objc_setAssociatedObject(self, $0, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        withUnsafePointer(to: &AssociatedKeys.bottomBar) {
            objc_setAssociatedObject(self, $0, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        withUnsafePointer(to: &AssociatedKeys.bottomBarAppearance) {
            objc_setAssociatedObject(self, $0, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        withUnsafePointer(to: &AssociatedKeys.popupController) {
            objc_setAssociatedObject(self, $0, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

internal extension UIViewController
{
    @objc func _animateBottomBarToHidden( _ hidden: Bool)
    {
        let height = self.popupController.bottomBarHeight
        
        // FIXME: iOS 14 beta 6 bug (toolbar frame animation fails)
        //let insets = self.insetsForBottomBar()
        
        if height > 0.0 {
            if hidden == false {
                //self.bottomBar.frame.origin.y = self.view.bounds.height - height - insets.bottom
                self.bottomBar.transform = .identity
            }
            else {
                self.bottomBar.transform = .identity
                //self.bottomBar.frame.origin.y = self.view.bounds.height
                let fromY = self.bottomBar.frame.minY
                let toY = self.view.bounds.height
                self.bottomBar.transform = self.bottomBar.transform.translatedBy(x: 0, y: toY - fromY)
            }
        }
    }
    
    @objc func _setBottomBarPosition( _ position: CGFloat)
    {
        let height = self.popupController.bottomBarHeight
        if height > 0.0 {
            self.bottomBar.frame.origin.y = position
        }
    }
    
    @objc func insetsForBottomBar() -> UIEdgeInsets
    {
        var insets: UIEdgeInsets = .zero
        if let dropShadowView = self.popupController.dropShadowViewFor(self.view) {
            if dropShadowView.frame.minX > 0 {
                return UIEdgeInsets.zero
            }
        }
        insets = self.view.window?.safeAreaInsets ?? UIEdgeInsets.zero
        if self.popupController.dataSource?.bottomBarView?(for: self.popupController) != nil {
            if let bottomBarInsets = self.popupController.dataSource?.popupController?(self.popupController, insetsFor: self.bottomBar) {
                insets = bottomBarInsets
            }
        }
        return insets
    }
    
    @objc func defaultFrameForBottomBar() -> CGRect
    {
        var bottomBarFrame = CGRect(x: 0.0, y: self.view.bounds.size.height, width: self.view.bounds.size.width, height: 0.0)
        if let bottomBarView = self.popupController.dataSource?.bottomBarView?(for: self.popupController) {
            if let defaultFrame = self.popupController.dataSource?.popupController?(self.popupController, defaultFrameFor: self.bottomBar) {
                return defaultFrame
            }
            else {
                bottomBarFrame = bottomBarView.frame
            }
        }
        bottomBarFrame.origin = CGPoint(x: bottomBarFrame.origin.x, y: self.view.bounds.height - (self.bottomBar.isHidden ? 0.0 : bottomBarFrame.size.height))
        return bottomBarFrame
    }
    
    @objc func configureScrollEdgeAppearanceForBottomBar() {
        // Do nothing for UIView
    }
    
    @objc func configurePopupBarFromBottomBar()
    {
        let toolBarAppearance = UIToolbarAppearance()
        self.popupBar.shadowColor = toolBarAppearance.shadowColor
        
        self.popupBar.backgroundColor = nil
        
        if self.popupBar.inheritsVisualStyleFromBottomBar == false {
            return
        }
        self.popupBar.tintColor = self.view.tintColor
    }
}

@inline(__always) func PBPopupFixInsetsForViewController(_ controller: UIViewController, _ layout: Bool, _ additionalSafeAreaInsets: UIEdgeInsets)
{
    if (controller is UITabBarController) || (controller is UINavigationController) || (controller.children.count > 0 && !(controller is UISplitViewController))
    {
        let oldInsets = controller.popupAdditionalSafeAreaInsets
        var insets = oldInsets
        if oldInsets.top != additionalSafeAreaInsets.top {
            insets.top += additionalSafeAreaInsets.top
        }
        if oldInsets.bottom != additionalSafeAreaInsets.bottom {
            insets.bottom += additionalSafeAreaInsets.bottom
        }
        if oldInsets != insets {
            controller.popupAdditionalSafeAreaInsets = PBFixInsetsForInsets(insets)
        }
        
        for (_, obj) in controller.children.enumerated() {
            let oldInsets = obj.popupAdditionalSafeAreaInsets
            var insets = oldInsets
            if oldInsets.top != additionalSafeAreaInsets.top {
                insets.top += additionalSafeAreaInsets.top
            }
            if oldInsets.bottom != additionalSafeAreaInsets.bottom {
                insets.bottom += additionalSafeAreaInsets.bottom
            }
            if oldInsets != insets {
                insets = PBFixInsetsForInsets(insets)
                obj.additionalSafeAreaInsets = insets
                obj.popupAdditionalSafeAreaInsets = insets
            }
        }
    } else {
        let oldInsets = controller.popupAdditionalSafeAreaInsets
        var insets = oldInsets
        if oldInsets.top != additionalSafeAreaInsets.top {
            insets.top += additionalSafeAreaInsets.top
        }
        if oldInsets.bottom != additionalSafeAreaInsets.bottom {
            insets.bottom += additionalSafeAreaInsets.bottom
        }
        if oldInsets != insets {
            insets = PBFixInsetsForInsets(insets)
            controller.additionalSafeAreaInsets = insets;
            controller.popupAdditionalSafeAreaInsets = insets;
        }
    }
    if (layout)
    {
        controller.view.setNeedsUpdateConstraints()
        controller.view.setNeedsLayout()
        controller.view.layoutIfNeeded()
    }
}

@inline(__always) func PBFixInsetsForInsets(_ insets: UIEdgeInsets) -> UIEdgeInsets {
    var insets = insets
    if insets.top < 0 {
        insets.top = 0
    }
    if insets.bottom < 0 {
        insets.bottom = 0
    }
    return insets
}
