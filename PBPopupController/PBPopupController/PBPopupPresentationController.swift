//
//  PBPopupPresentationController.swift
//  PBPopupController
//
//  Created by Patrick BODET on 13/07/2018.
//  Copyright © 2018-2020 Patrick BODET. All rights reserved.
//

import UIKit

internal class PBPopupPresentationController: UIPresentationController {
    
    internal weak var presentingVC: UIViewController!
    internal weak var popupController: PBPopupController!
    private var popupPresentationState: PBPopupPresentationState {
        return popupController.popupPresentationState
    }
    
    private var backingView: UIView!
    
    private var shouldUpdateBackingView: Bool = true
    
    internal var popupPresentationStyle = PBPopupPresentationStyle.deck
    internal var isPresenting = false
    
    internal var animator: UIViewPropertyAnimator!
    private weak var contextData: UIViewControllerContextTransitioning!
    
    private var popupContentView: PBPopupContentView! {
        return popupController.containerViewController.popupContentView
    }
    
    private func dropShadowViewFor(_ view: UIView) -> UIView? {
        return popupController.dropShadowViewFor(view)
    }
    
    private var popupContentViewTopInset: CGFloat {
        #if targetEnvironment(macCatalyst)
        return 10.0
        #else
        if self.dropShadowViewFor(self.presentingVC.view) != nil {
            return 0.0
        }
        return UIDevice.current.userInterfaceIdiom == .pad ? 10.0 : 10.0
        #endif
    }
    
    private var statusBarFrame: CGRect {
        var frame = self.popupController.statusBarFrame(for: self.popupController.containerViewController.view)
        if self.popupPresentationStyle == .deck, frame.height == 0 {
            let height = presentingVC.view.safeAreaInsets.top
            frame.size.height = height > 0 ? height : 20 // probably an old iPhone
        }
        if self.dropShadowViewFor(self.presentingVC.view) != nil {
            frame.size.height = 0.0
        }
        return frame
    }
    
    internal var bottomBarForPresentation: UIView!
    
    internal var popupBarForPresentation: UIView!
    
    internal var imageViewForPresentation: PBPopupRoundShadowImageView?
    
    private var bottomModuleFrameForPopupStateOpen: CGRect = .zero
    
    private var dimmerView: UIView = {
        let view = UIView()
        view.autoresizingMask = []
        view.backgroundColor = UIColor.black
        view.alpha = 0.0
        view.clipsToBounds = true
        return view
    }()
    
    private var blackView: UIView = {
        let view = UIView()
        view.autoresizingMask = []
        view.backgroundColor = UIColor.black
        view.alpha = 1.0
        return view
    }()
    
    private var popupBarView: PBPopupBarView! {
        get {
            return popupController.popupBarView
        }
    }
    
    private var touchForwardingView: PBTouchForwardingView!
    
    private class PBTouchForwardingView: UIView {
        
        var passthroughViews: [UIView] = []
        weak var popupController: PBPopupController!
        
        override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
            guard let hitView = super.hitTest(point, with: event) else { return nil }
            guard hitView == self else { return hitView }
            
            if event == nil {
                return self
            }
            #if targetEnvironment(macCatalyst)
            if #available(macCatalyst 13.4, *) {
                if event?.type == .hover {
                    return self
                }
            }
            #endif
            
            for passthroughView in passthroughViews {
                let point = convert(point, to: passthroughView)
                if passthroughView.hitTest(point, with: event) != nil {
                    if popupController.containerViewController.popupContentView.popupCanDismissOnPassthroughViews {
                        popupController.closePopupContent()
                    }
                    return nil
                }
            }
            return self
        }
    }
    
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        self.presentingVC = presentingViewController
    }
    
    deinit {
        PBLog("deinit \(self)")
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        var frame = CGRect.zero
        frame = self.popupContentViewFrameForPopupStateOpen()
        frame.origin.x = 0.0
        frame.origin.y = 0.0
        return frame
    }
    
    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        
        self.popupContentView.frame = self.popupContentViewFrameForPopupStateOpen()
        self.presentedView?.frame = self.frameOfPresentedViewInContainerView
    }
    
    override func containerViewDidLayoutSubviews() {
        super.containerViewDidLayoutSubviews()
    }
    
    override func presentationTransitionWillBegin()
    {
        guard let presentedView = self.presentedView,
              let containerView = self.containerView,
              let coordinator = self.presentedViewController.transitionCoordinator
        else {
            return
        }
        
        containerView.frame = self.frameForContainerView()
        
        var frame = containerView.bounds
        frame.size.height -= self.popupBarView.frame.height
        self.touchForwardingView = PBTouchForwardingView(frame: frame)
        self.touchForwardingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.touchForwardingView.passthroughViews = [self.presentingVC.view]
        self.touchForwardingView.popupController = self.popupController
        containerView.insertSubview(touchForwardingView, at: 0)
        
        self.setupBackingView()
        
        self.popupContentView.contentView.addSubview(presentedView)
        self.popupContentView.contentView.sendSubviewToBack(presentedView)
        
        self.popupContentView.isHidden = true
        containerView.addSubview(self.popupContentView)
        
        self.popupBarForPresentation = self.setupPopupBarForPresentation()
        if let popupBarForPresentation = self.popupBarForPresentation {
            self.popupContentView.contentView.addSubview(popupBarForPresentation)
        }
        
        self.imageViewForPresentation = self.setupImageViewForPresentation()
        if self.imageViewForPresentation != nil {
            self.popupContentView.contentView.addSubview(self.imageViewForPresentation!)
        }
        
        coordinator.animate(alongsideTransition: { (context) in
            if !context.isInteractive {
                self.popupBarForPresentation?.alpha = 0.0
            }
            self.popupContentView.updatePopupCloseButtonPosition()
        })
    }
    
    override func presentationTransitionDidEnd(_ completed: Bool) {
        self.bottomBarForPresentation?.removeFromSuperview()
        self.bottomBarForPresentation = nil
        self.popupBarForPresentation?.removeFromSuperview()
        self.popupBarForPresentation = nil
        self.imageViewForPresentation?.removeFromSuperview()
        self.imageViewForPresentation = nil
        if !completed {
            self._cleanup()
        }
        else {
            self.blackView.alpha = 1.0
            NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground(_:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
        }
    }
    
    @objc func didEnterBackground(_ sender: Any) {
        self.shouldUpdateBackingView = false
        delay(2) {
            self.shouldUpdateBackingView = true
        }
    }
    
    override func dismissalTransitionWillBegin()
    {
        guard let coordinator = self.presentedViewController.transitionCoordinator
        else {
            return
        }
        
        self.popupBarForPresentation = self.setupPopupBarForPresentation()
        if let popupBarForPresentation = self.popupBarForPresentation {
            self.popupContentView.contentView.addSubview(popupBarForPresentation)
        }
        
        self.imageViewForPresentation = self.setupImageViewForPresentation()
        if self.imageViewForPresentation != nil {
            self.popupContentView.contentView.addSubview(self.imageViewForPresentation!)
            self.configureImageViewInStartPosition()
        }
        
        self.backingView?.removeFromSuperview()
        self.backingView = nil
        self.setupBackingView()
        self.animateBackingViewToDeck(true, animated: false)
        
        self.popupBarForPresentation?.alpha = 0.0
        coordinator.animate(alongsideTransition: { (context) in
            self.animateBackingViewToDeck(false, animated: true)
            if !context.isInteractive {
                self.popupBarForPresentation?.alpha = 1.0
                self.animateImageViewInFinalPosition()
            }
            self.setupCornerRadiusForPopupContentViewAnimated(true, open: false)
        })
    }
    
    internal func continueDismissalTransitionWithTimingParameters(_ timingParameters: UITimingCurveProvider?, durationFactor: CGFloat) {
        if let animator = self.animator {
            animator.addAnimations {
                self.popupContentView.popupCloseButton?.alpha = 0.0
                self.popupBarForPresentation?.alpha = 1.0
                self.popupContentView.center = self.popupContentViewCenterForPopupStateClosed(true)
                self.popupContentView.bounds = self.popupContentViewBoundsForPopupStateClosed(true)
                
                self.animateImageViewInFinalPosition()
                self._animateBottomBarToHidden(false)
            }
            animator.continueAnimation(withTimingParameters: timingParameters, durationFactor: durationFactor)
        }
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        self.bottomBarForPresentation?.removeFromSuperview()
        self.bottomBarForPresentation = nil
        self.popupBarForPresentation?.removeFromSuperview()
        self.popupBarForPresentation = nil
        self.imageViewForPresentation?.removeFromSuperview()
        self.imageViewForPresentation = nil
        
        if completed {
            self._cleanup()
        }
        else {
            self.blackView.alpha = 1.0
        }
    }
    
    private func _cleanup() {
        if self.popupPresentationStyle == .deck {
            self.backingView?.removeFromSuperview()
            self.backingView = nil
            self.blackView.removeFromSuperview()
            self.dimmerView.removeFromSuperview()
        }
        self.touchForwardingView.removeFromSuperview()
        self.touchForwardingView = nil
        self.presentedView?.removeFromSuperview()
        self.popupContentView.removeFromSuperview()
        self.contextData = nil
    }
}

extension PBPopupPresentationController: UIViewControllerAnimatedTransitioning
{
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval
    {
        return self.isPresenting ? self.popupContentView.popupPresentationDuration : self.popupContentView.popupDismissalDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning)
    {
        let animator = self.interruptibleAnimator(using: transitionContext)
        animator.startAnimation()
    }
    
    func interruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating
    {
        if self.animator != nil {
            return self.animator!
        }
        self.contextData = transitionContext
        let presentedView = transitionContext.view(forKey: self.isPresenting ? .to : .from)
        
        var animator: UIViewPropertyAnimator!
        
        presentedView?.setNeedsLayout()
        presentedView?.layoutIfNeeded()
        
        presentedView?.clipsToBounds = false
        presentedView?.autoresizingMask = []
        
        if self.isPresenting {
            self.popupContentView.frame = self.popupContentViewFrameForPopupStateClosed(false)
            presentedView?.frame = self.presentedViewFrameForPopupStateClosed()
            
            self.popupContentView.isHidden = false
            
            self.popupContentView.popupCloseButton?.alpha = 0.0
            
            self.setupCornerRadiusForPopupContentViewAnimated(false, open: false)
            
            self.configureImageViewInStartPosition()
            self.configureBottomModuleInStartPosition()
            
            let animations = {
                self.popupContentView.frame = self.popupContentViewFrameForPopupStateOpen()
                presentedView?.frame = self.presentedViewFrameForPopupStateOpen()
                
                self.animateBackingViewToDeck(true, animated: true)
                self.animateImageViewInFinalPosition()
                self.animateBottomModuleInFinalPosition()
                self._animateBottomBarToHidden(true)
                
                self.setupCornerRadiusForPopupContentViewAnimated(true, open: true)
                
                if !transitionContext.isInteractive {
                    self.popupContentView.popupCloseButton?.alpha = 1.0
                }
            }
            
            let completion: (() -> Void) = {() -> Void in
                self.popupContentView.popupImageView?.isHidden = false
                self.popupContentView.popupImageModule?.isHidden = false
                if transitionContext.transitionWasCancelled {
                    self.popupContentView.popupCloseButton?.setButtonStateStationary()
                    
                    // Restore the initial frame after cancel presenting
                    self.configureBottomModuleInOriginalPosition()
                }
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
            
            popupContentView.popupCloseButton?.alpha = 0.0
            popupContentView.popupCloseButton?.setButtonStateStationary()
            
            let curve: UIView.AnimationCurve = transitionContext.isInteractive ? .easeInOut : .easeInOut
            animator = UIViewPropertyAnimator(duration: self.transitionDuration(using: transitionContext), curve: curve, animations: {
                animations()
            })
            animator.addCompletion { (_) in
                completion()
            }
        }
        else {
            // Dismiss
            self.popupContentView.frame = self.popupContentViewFrameForPopupStateOpen()
            presentedView?.frame = self.presentedViewFrameForPopupStateOpen()
            
            self.popupBarView.alpha = 0.0
            
            let animations = {
                self.popupContentView.center = self.popupContentViewCenterForPopupStateClosed(false)
                self.popupContentView.bounds = self.popupContentViewBoundsForPopupStateClosed(false)
                presentedView?.center = self.presentedViewCenterForPopupStateClosed()
                presentedView?.bounds = self.presentedViewBoundsForPopupStateClosed()
                
                if !transitionContext.isInteractive {
                    self._animateBottomBarToHidden(false)
                    self.popupContentView.popupCloseButton?.alpha = 0.0
                }
            }
            
            let completion = {
                self.popupBarView.alpha = 1.0
                self.popupContentView.popupImageView?.isHidden = false
                self.popupContentView.popupImageModule?.isHidden = false
                
                self.popupContentView.popupCloseButton?.setButtonStateStationary()
                
                // Restore the initial frame after dismiss
                self.configureBottomModuleInOriginalPosition()
                
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
            
            self.popupContentView.popupCloseButton?.setButtonStateTransitioning()
            
            var timingParameters: UITimingCurveProvider
            if transitionContext.isInteractive {
                let curve: UIView.AnimationCurve = .linear
                timingParameters = UICubicTimingParameters(animationCurve: curve)
            }
            else {
                if self.dropShadowViewFor(self.presentingVC.view) != nil, self.popupPresentationStyle == .deck {
                    timingParameters = UICubicTimingParameters(animationCurve: .easeInOut)
                }
                else {
                    timingParameters = UISpringTimingParameters(dampingRatio: 1, initialVelocity: CGVector(dx: 0, dy: 0))
                }
            }
            animator = UIViewPropertyAnimator(duration: self.transitionDuration(using: transitionContext), timingParameters: timingParameters)
            animator.addAnimations {
                animations()
            }
            animator.addCompletion { (_) in
                completion()
            }
        }
        
        if transitionContext.isInteractive {
            animator.startAnimation()
            animator.pauseAnimation()
            transitionContext.pauseInteractiveTransition()
        }
        
        self.animator = animator
        return animator
    }
    
    func initialAnimationVelocity(for gestureVelocity: CGFloat, distance: CGFloat) -> CGVector {
        var animationVelocity = CGVector.zero
        if distance != 0 {
            animationVelocity.dy = gestureVelocity / distance
        }
        return animationVelocity
    }
    
    func animationEnded(_ transitionCompleted: Bool) {
        self.animator = nil
        #if DEBUG
        delay(1) {
            // prove the context goes out of existence in good order
            PBLog("contextData: \(self.contextData as Any)")
        }
        #endif
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #available(iOS 13.0, *) {
            guard previousTraitCollection != nil, let backingView = self.backingView, self.shouldUpdateBackingView == true else { return }
            if self.traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle {
                backingView.removeFromSuperview()
                self.backingView = nil
                self.setupBackingView()
                self.animateBackingViewToDeck(true, animated: false)
            }
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        // Let's restore original frames before animations
        if let dropShadowView = self.dropShadowViewFor(self.presentingVC.view) {
            dropShadowView.superview?.transform = .identity
        }
        self.containerView?.frame = self.frameForContainerView()
        
        coordinator.animate(alongsideTransition: { (context) in
            if self.popupPresentationState == .open {
                if let dropShadowView = self.dropShadowViewFor(self.presentingVC.view) {
                    dropShadowView.superview?.transform = .identity
                }
                self.containerView?.frame = self.frameForContainerView()
                self.blackView.frame = self.popupBlackViewFrame()
                self.blackView.isHidden = self.isCompactOrPhoneInLandscape() ? true : false

                if self.traitCollection.verticalSizeClass == .regular, let backingView = self.backingView {
                    backingView.removeFromSuperview()
                    self.backingView = nil
                }
                self.setupBackingView()
                self.animateBackingViewToDeck(true, animated: false)
                self.popupContentView.frame = self.popupContentViewFrameForPopupStateOpen()
                self.setupCornerRadiusForPopupContentViewAnimated(true, open: true)
                self.popupContentView.updatePopupCloseButtonPosition()
            }
        }) { (context) in
            if let bottomModule = self.popupContentView.popupBottomModule {
                self.bottomModuleFrameForPopupStateOpen = bottomModule.frame
            }
        }
    }
}

// MARK: - Frames

extension PBPopupPresentationController
{
    private func frameForContainerView() -> CGRect {
        var frame = self.presentingVC.view.frame
        if let dropShadowView = self.dropShadowViewFor(self.presentingVC.view) {
            frame = dropShadowView.frame
            frame.origin.x += self.presentingVC.view.frame.minX
            frame.size.width = self.presentingVC.view.frame.width
        }
        frame.size.height -= self.popupBarView.frame.height
        return frame
    }
    
    private func popupBlackViewFrame() -> CGRect {
        var frame = self.popupContentViewFrameForPopupStateOpen()
        frame.origin.y = 0
        if self.dropShadowViewFor(self.presentingVC.view) != nil {
            frame.size.height += frame.minY
        }
        else {
            frame.size.height = self.presentingVC.defaultFrameForBottomBar().minY - self.presentingVC.insetsForBottomBar().bottom
        }
        PBLog("\(frame)")
        return frame
    }
    
    internal func popupContentViewFrameForPopupStateClosed(_ finish: Bool) -> CGRect {
        var frame: CGRect = .zero
        if !self.isPresenting && self.contextData.isInteractive && !finish {
            frame = self.presentingVC.defaultFrameForBottomBar()
            frame.origin.x = self.popupController.popupBarViewFrameForPopupStateClosed().origin.x
            frame.size.width = self.popupController.popupBarViewFrameForPopupStateClosed().width
        }
        else {
            frame = self.popupController.popupBarViewFrameForPopupStateClosed()
            if self.dropShadowViewFor(self.presentingVC.view) != nil, self.popupPresentationStyle == .deck {
                frame.size.height += (self.presentingVC.defaultFrameForBottomBar().height + self.presentingVC.insetsForBottomBar().bottom)
            }
        }
        if #available(iOS 14, *), UIDevice.current.userInterfaceIdiom == .pad, let svc = self.presentingVC.splitViewController, self.dropShadowViewFor(svc.view) != nil {
            let x = self.presentingVC.view.safeAreaInsets.left
            frame.origin.x = x
            frame.size.width -= x
        }
        PBLog("\(frame)")
        return frame
    }
    
    internal func popupContentViewCenterForPopupStateClosed(_ finish: Bool) -> CGPoint {
        return self.popupContentViewFrameForPopupStateClosed(finish).center
    }
    
    internal func popupContentViewBoundsForPopupStateClosed(_ finish: Bool) -> CGRect {
        var frame = self.popupContentViewFrameForPopupStateClosed(finish)
        frame.origin = .zero
        return frame
    }
    
    private func presentedViewFrameForPopupStateClosed() -> CGRect {
        var frame = self.popupContentViewFrameForPopupStateClosed(false)
        frame.origin.x = 0
        frame.origin.y = 0
        frame.size.height = self.popupContentViewFrameForPopupStateOpen().height
        PBLog("\(frame)")
        return frame
    }
    
    private func presentedViewCenterForPopupStateClosed() -> CGPoint {
        return self.presentedViewFrameForPopupStateClosed().center
    }
    
    private func presentedViewBoundsForPopupStateClosed() -> CGRect {
        var frame = self.presentedViewFrameForPopupStateClosed()
        frame.origin = .zero
        return frame
    }
    
    internal func popupContentViewFrameForPopupStateOpen() -> CGRect {
        guard let containerView = self.containerView else { return .zero }
        
        var y: CGFloat = 0.0
        
        let height = self.presentingVC.view.bounds.height
        
        #if targetEnvironment(macCatalyst)
        if self.popupPresentationStyle == .fullScreen {
            //y = self.statusBarFrame.height
        }
        #endif
        
        if self.popupPresentationStyle == .deck && self.traitCollection.verticalSizeClass == .regular && self.presentingVC.splitViewController == nil {
            y = self.statusBarFrame.height + self.popupContentViewTopInset
        }
        else if self.popupPresentationStyle == .custom {
            y = height - self.popupContentView.popupContentSize.height
        }
        
        var frame = CGRect(x: self.presentingVC.defaultFrameForBottomBar().origin.x, y: y, width: self.presentingVC.defaultFrameForBottomBar().size.width, height: height - y)

        if self.presentingVC is UINavigationController || self.presentingVC is UITabBarController {
            frame = CGRect(x: 0.0, y: y, width: containerView.bounds.width, height: height - y)
            
            if #available(iOS 14, *), UIDevice.current.userInterfaceIdiom == .pad, let svc = self.presentingVC.splitViewController, self.dropShadowViewFor(svc.view) != nil {
                let x = self.presentingVC.view.safeAreaInsets.left
                frame = CGRect(x: x, y: y, width: containerView.bounds.width - x, height: height - y)
            }
        }
        PBLog("\(frame)")
        return frame
    }
    
    private func presentedViewFrameForPopupStateOpen() -> CGRect {
        var frame = self.popupContentViewFrameForPopupStateOpen()
        frame.origin.x = 0
        frame.origin.y = 0
        PBLog("\(frame)")
        return frame
    }
    
    // MARK: - Corner radii
    
    internal func setupCornerRadiusForBackingViewAnimated(_ animated: Bool, open: Bool) {
        if self.backingView == nil {
            return
        }
        else {
            if #available(iOS 13.0, *) {
                self.backingView.layer.cornerCurve = .continuous
            }
            var cornerRadius: CGFloat = 0.0
            var cornerRadiusForClose: CGFloat = 0.0
            
            let popupIgnoreDropShadowView = self.popupContentView.popupIgnoreDropShadowView
            self.popupContentView.popupIgnoreDropShadowView = false
            if let dropShadowView = self.dropShadowViewFor(self.presentingVC.view) {
                if #available(iOS 13.0, *) {
                    self.backingView.layer.cornerCurve = dropShadowView.layer.cornerCurve
                }
                if open == false {
                    cornerRadius = dropShadowView.layer.cornerRadius
                    cornerRadiusForClose = dropShadowView.layer.cornerRadius
                }
            }
            self.popupContentView.popupIgnoreDropShadowView = popupIgnoreDropShadowView
            
            if open && cornerRadius == 0 {
                #if targetEnvironment(macCatalyst)
                cornerRadius = 7.0
                #else
                cornerRadius = 10.0
                #endif
            }
            if !animated {
                self.backingView.setupCornerRadiusTo(open ? cornerRadius : cornerRadiusForClose, rect: self.backingView.bounds)
            }
            else {
                self.backingView.updateCornerRadiusTo(open ? cornerRadius : cornerRadiusForClose, rect: self.backingView.bounds)
            }
        }
    }
    
    internal func setupCornerRadiusForPopupContentViewAnimated(_ animated: Bool, open: Bool) {
        if let svc = self.presentingVC.splitViewController, self.dropShadowViewFor(svc.view) == nil, self.popupPresentationStyle != .custom { return }
        
        self.popupContentView.layer.cornerRadius = 0.0
        if let dropShadowView = self.dropShadowViewFor(self.presentingVC.view) {
            if UIDevice.current.userInterfaceIdiom == .phone {
                if self.popupController.containerViewController.splitViewController != nil, self.isCompactOrPhoneInLandscape() {
                    return
                }
                self.popupContentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                self.popupContentView.layer.cornerRadius = open ? dropShadowView.layer.cornerRadius : 0.0
            }
            else {
                self.popupContentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                if let svc = self.presentingVC.splitViewController, self.popupPresentationStyle != .custom {
                    if svc.viewControllers.firstIndex(of: self.presentingVC) == 0 {
                        self.popupContentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                    }
                    else if svc.viewControllers.firstIndex(of: self.presentingVC) == 1 {
                        self.popupContentView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                    }
                }
                self.popupContentView.layer.cornerRadius = open ? dropShadowView.layer.cornerRadius : 0.0
            }
        }
        else {
            var cornerRadius: CGFloat = 0.0
            if self.popupPresentationStyle == .fullScreen {
                let popupIgnoreDropShadowView = self.popupContentView.popupIgnoreDropShadowView
                self.popupContentView.popupIgnoreDropShadowView = false
                if let dropShadowView = self.dropShadowViewFor(self.presentingVC.view) {
                    if #available(iOS 13.0, *) {
                        self.popupContentView.layer.cornerCurve = dropShadowView.layer.cornerCurve
                    }
                    cornerRadius = dropShadowView.layer.cornerRadius
                }
                self.popupContentView.popupIgnoreDropShadowView = popupIgnoreDropShadowView
            }
            if open && cornerRadius == 0 {
                #if targetEnvironment(macCatalyst)
                cornerRadius = 7.0
                #else
                cornerRadius = 10.0
                #endif
            }
            if self.traitCollection.verticalSizeClass == .compact {
                cornerRadius = 0.0
            }
            if !animated {
                self.popupContentView.setupCornerRadiusTo(open ? cornerRadius : 0.0, rect: self.popupContentViewFrameForPopupStateOpen())
            }
            else {
                self.popupContentView.updateCornerRadiusTo(open ? cornerRadius : 0.0, rect: self.popupContentViewFrameForPopupStateOpen())
            }
        }
    }
    
    // MARK: - Snapshot views
    
    private func setupBackingView()
    {
        if self.popupPresentationStyle == .custom { return }

        if self.presentingVC.splitViewController != nil { return }
        
        if let dropShadowView = self.dropShadowViewFor(self.presentingVC.view) {
            
            if self.popupPresentationStyle == .fullScreen { return }
            
            self.dimmerView.frame = dropShadowView.bounds
            self.dimmerView.layer.cornerRadius = dropShadowView.layer.cornerRadius
            dropShadowView.addSubview(self.dimmerView)
            return
        }
        
        if self.traitCollection.verticalSizeClass == .regular && self.backingView == nil {
            let isHidden = self.popupBarView.isHidden
            self.popupBarView.isHidden = true
            let alpha = self.popupBarView.alpha
            self.popupBarView.alpha = 0.0
                        
            self.blackView.frame = self.popupBlackViewFrame()
            
            var imageRect = self.blackView.bounds
            
            let x = self.presentingVC.view.frame.minX
            if x < 0 {
                imageRect.origin.x = -x
                imageRect.size.width += x
            }
            
            //for debug
            //let image = presentingVC.view.makeSnapshot(from: imageRect)
            
            var snapshotView = self.presentingVC.view!
            if let nc = self.presentingVC.navigationController {
                snapshotView = nc.view
            }
            self.backingView = snapshotView.resizableSnapshotView(from: imageRect, afterScreenUpdates: true, withCapInsets: .zero)
            self.backingView.autoresizingMask = []
            
            self.popupBarView.isHidden = isHidden
            self.popupBarView.alpha = alpha
            
            self.backingView.frame = imageRect
            
            self.backingView.clipsToBounds = true
            
            self.setupCornerRadiusForBackingViewAnimated(false, open: false)
            
            self.dimmerView.frame = self.backingView.bounds
            self.backingView.addSubview(self.dimmerView)
            
            if self.blackView.window == nil {
                self.containerView?.addSubview(self.blackView)
                self.containerView?.sendSubviewToBack(self.blackView)
            }
            self.blackView.addSubview(self.backingView)
        }
    }
    
    private func animateBackingViewToDeck( _ deck: Bool, animated: Bool)
    {
        if self.popupPresentationStyle == .custom { return }

        if self.presentingVC.splitViewController != nil { return }

        if self.traitCollection.verticalSizeClass == .regular {
            if deck == true {
                self.dimmerView.alpha = 0.2
                
                let scaledXY = (self.presentingVC.view.bounds.width - self.presentingVC.view.layoutMargins.right * 2) / self.presentingVC.view.bounds.width
                
                if let dropShadowView = self.dropShadowViewFor(self.presentingVC.view) {
                    
                    if self.popupPresentationStyle == .fullScreen { return }
                    
                    let translatedY = dropShadowView.bounds.height * ((1 - scaledXY) / 2) + 10
                    dropShadowView.superview?.transform = CGAffineTransform(a: scaledXY, b: 0.0, c: 0.0, d: scaledXY, tx: 1.0, ty: -translatedY)
                }
                else {
                    self.backingView.transform = .identity
                    let translatedY = self.statusBarFrame.height - (self.statusBarFrame.height > 0 ? (self.backingView.bounds.height * (1 - scaledXY) / 2) : 0.0)
                    self.backingView.transform = CGAffineTransform(a: scaledXY, b: 0.0, c: 0.0, d: scaledXY, tx: 1.0, ty: translatedY)
                    self.setupCornerRadiusForBackingViewAnimated(animated, open: true)
                }
            }
            else {
                self.dimmerView.alpha = 0.0
                if let dropShadowView = self.dropShadowViewFor(self.presentingVC.view) {
                    dropShadowView.superview?.transform = .identity
                }
                else {
                    self.setupCornerRadiusForBackingViewAnimated(animated, open: false)
                    self.backingView.transform = .identity
                }
            }
        }
    }
    
    private func setupPopupBarForPresentation() -> UIView?
    {
        let alpha = self.popupBarView.alpha
        self.popupBarView.alpha = 1.0
        
        self.presentingVC.popupBar.setHighlighted(false, animated: false)
        
        if !self.isCompactOrPhoneInLandscape() && self.popupContentView.popupImageView != nil {
            self.presentingVC.popupBar.imageView.isHidden = true
        }
        
        var rect = self.popupBarView.frame
        rect.origin.x = self.popupContentViewFrameForPopupStateOpen().minX
        rect.size.width = self.popupContentViewFrameForPopupStateOpen().width

        //for debug
        //let image = self.presentingVC.view.makeSnapshot(from: rect)
        
        let view = self.presentingVC.view.resizableSnapshotView(from: rect, afterScreenUpdates: true, withCapInsets: .zero)
        
        if self.presentingVC.popupBar.popupBarStyle == .prominent {
            self.presentingVC.popupBar.imageView.isHidden = false
        }
        
        self.popupBarView.alpha = alpha
        
        return view
    }
    
    // MARK: - Bottom bar
    
    internal func _animateBottomBarToHidden( _ hidden: Bool) {
        if self.dropShadowViewFor(self.presentingVC.view) == nil || (self.dropShadowViewFor(self.presentingVC.view) != nil && self.popupPresentationStyle != .deck) {
            self.presentingVC._animateBottomBarToHidden(hidden)
        }
    }
    
    // MARK: - Image view
    
    private func setupImageViewForPresentation() -> PBPopupRoundShadowImageView?
    {
        if self.isCompactOrPhoneInLandscape() {return nil}
        
        if self.presentingVC.popupBar.popupBarStyle == .prominent, let imageView = self.popupContentView.popupImageView {
            
            let moduleView = PBPopupRoundShadowImageView(frame: imageView.frame)
            
            moduleView.image = imageView.image
            moduleView.imageView.backgroundColor = imageView.backgroundColor
            moduleView.imageView.contentMode = imageView.contentMode
            moduleView.imageView.clipsToBounds = imageView.clipsToBounds
            
            if let imageModule = self.popupContentView.popupImageModule {
                moduleView.clipsToBounds = imageModule.clipsToBounds
                moduleView.shadowColor = UIColor(cgColor: imageModule.layer.shadowColor ?? UIColor.black.cgColor)
                moduleView.shadowOffset = imageModule.layer.shadowOffset
                moduleView.shadowOpacity = imageModule.layer.shadowOpacity
                moduleView.shadowRadius = imageModule.layer.shadowRadius
            }
            return moduleView
        }
        return nil
    }
    
    private func configureImageViewInStartPosition()
    {
        if self.isCompactOrPhoneInLandscape() {return}
        
        guard let presentedView = self.presentedView else { return }
        guard let popupBar = self.presentingVC.popupBar else { return }
        guard popupBar.popupBarStyle == .prominent else { return }
        guard let imageViewForPresentation = self.imageViewForPresentation else { return }
        guard let imageView = self.popupContentView.popupImageView else { return }
        
        if self.isPresenting {
            var closedFrame = popupBar.imageView.frame
            
            closedFrame.origin.x -= self.popupContentViewFrameForPopupStateOpen().minX
            if closedFrame.origin.x < 0 {
                closedFrame.origin.x = popupBar.imageView.frame.minX
            }
            
            imageViewForPresentation.frame = closedFrame
            imageViewForPresentation.cornerRadius = 3.0
        }
        else {
            let openFrame = imageView.convert(imageView.bounds, to: presentedView)
            imageViewForPresentation.frame = openFrame
            imageViewForPresentation.cornerRadius = imageView.layer.cornerRadius
            imageViewForPresentation.isHidden = false
        }
        imageView.isHidden = true
        if let imageModule = self.popupContentView.popupImageModule {
            imageModule.isHidden = true
        }
    }
    
    internal func animateImageViewInFinalPosition()
    {
        if self.isCompactOrPhoneInLandscape() {return}
        
        guard let presentedView = self.presentedView else { return }
        guard let popupBar = self.presentingVC.popupBar else { return }
        guard popupBar.popupBarStyle == .prominent else { return }
        guard let imageViewForPresentation = self.imageViewForPresentation else { return }
        guard let imageView = self.popupContentView.popupImageView else { return }
        
        if self.isPresenting {
            let openFrame = imageView.convert(imageView.bounds, to: presentedView)
            imageViewForPresentation.frame = openFrame
            imageViewForPresentation.cornerRadius = imageView.layer.cornerRadius
        }
        else {
            var closedFrame = popupBar.imageView.frame
            
            closedFrame.origin.x -= self.popupContentViewFrameForPopupStateOpen().minX
            if closedFrame.origin.x < 0 {
                closedFrame.origin.x = popupBar.imageView.frame.minX
            }
            
            imageViewForPresentation.center = closedFrame.center
            closedFrame.origin = .zero
            imageViewForPresentation.bounds = closedFrame
            
            imageViewForPresentation.cornerRadius = 3.0
        }
    }
    
    // MARK: - Bottom module
    
    private func configureBottomModuleInStartPosition()
    {
        guard let popupBar = self.presentingVC.popupBar else { return }
        guard popupBar.popupBarStyle == .prominent else { return }
        guard let imageViewForPresentation = self.imageViewForPresentation else { return }
        guard let imageView = self.popupContentView.popupImageView else { return }
        guard let topModule = self.popupContentView.popupTopModule else { return }
        guard let bottomModule = self.popupContentView.popupBottomModule else { return }
        guard let bottomModuleTopConstraint = self.popupContentView.popupBottomModuleTopConstraint else { return }
        
        if self.isPresenting {
            let openFrame = bottomModule.frame
            
            // Save the bottom module real position when open
            self.bottomModuleFrameForPopupStateOpen = openFrame
            
            // Move up bottom module just below imageForPresentation
            bottomModule.frame.origin.y = topModule.frame.origin.y + topModule.frame.height + bottomModuleTopConstraint.constant - (imageView.frame.size.height - imageViewForPresentation.frame.size.height)
        }
        else {
            if self.bottomModuleFrameForPopupStateOpen != .zero {
                bottomModule.frame = self.bottomModuleFrameForPopupStateOpen
            }
        }
    }
    
    internal func animateBottomModuleInFinalPosition()
    {
        guard let popupBar = self.presentingVC.popupBar else { return }
        guard popupBar.popupBarStyle == .prominent else { return }
        guard self.imageViewForPresentation != nil else { return }
        guard let topModule = self.popupContentView.popupTopModule else { return }
        guard let bottomModule = self.popupContentView.popupBottomModule else { return }
        guard let bottomModuleTopConstraint = self.popupContentView.popupBottomModuleTopConstraint else { return }
        
        if self.isPresenting {
            // Animate bottom module frame to its open position
            bottomModule.frame = self.bottomModuleFrameForPopupStateOpen
        }
        else {
            bottomModule.frame.origin.y = topModule.frame.origin.y + topModule.frame.height + bottomModuleTopConstraint.constant
        }
    }
    
    private func configureBottomModuleInOriginalPosition()
    {
        guard let popupBar = self.presentingVC.popupBar else { return }
        guard popupBar.popupBarStyle == .prominent else { return }
        guard let bottomModule = self.popupContentView.popupBottomModule else { return }
        
        if self.bottomModuleFrameForPopupStateOpen != .zero {
            bottomModule.frame = self.bottomModuleFrameForPopupStateOpen
        }
    }
    
    // MARK: - Helpers
    
    private func isCompactOrPhoneInLandscape() -> Bool {
        if self.traitCollection.verticalSizeClass == .compact {return true}
        let orientation = self.popupController.statusBarOrientation(for: self.popupController.containerViewController.view)
        return UIDevice.current.userInterfaceIdiom == .phone && (orientation == .landscapeLeft || orientation == .landscapeRight)
    }
    
    private func delay(_ delay:Double, closure:@escaping ()->()) {
        let when = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
    }
    
    private func _viewFor(_ view: UIView?, selfOrSuperviewKindOf aClass: AnyClass) -> UIView? {
        if view?.classForCoder == aClass {
            return view
        }
        var superview: UIView? = view?.superview
        while superview != nil {
            if superview?.classForCoder == aClass {
                return superview
            }
            superview = superview?.superview
        }
        return nil
    }
}
