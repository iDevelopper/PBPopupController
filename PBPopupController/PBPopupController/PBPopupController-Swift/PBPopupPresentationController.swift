//
//  PBPopupPresentationController.swift
//  PBPopupController
//
//  Created by Patrick BODET on 13/07/2018.
//  Copyright © 2018-2023 Patrick BODET. All rights reserved.
//

import UIKit

internal class PBPopupPresentationController: UIPresentationController
{
    internal weak var presentingVC: UIViewController!
    
    internal weak var popupController: PBPopupController!
    
    private var popupPresentationState: PBPopupPresentationState
    {
        return popupController.popupPresentationState
    }
    
    internal var backingView: UIView!

    private var shouldUpdateBackingView: Bool = true
    
    internal var popupPresentationStyle = PBPopupPresentationStyle.deck {
        didSet {
            if self.popupPresentationStyle == .custom { return }
            
            if self.popupPresentationStyle == .popup { return }
            
            if self.popupController.isContainerPresentationSheet {
                popupPresentationStyle = .fullScreen
            }
            if self.presentingVC.splitViewController != nil {
                popupPresentationStyle = .fullScreen
            }
            self.popupContentView.popupPresentationStyle = popupPresentationStyle
        }
    }
    
    internal var isPresenting = false
    
    internal var animator: UIViewPropertyAnimator!
    
    private var finishAnimator: UIViewPropertyAnimator!
    
    private var popupContentView: PBPopupContentView!
    {
        return popupController.containerViewController.popupContentView
    }
        
    private func dropShadowViewFor(_ view: UIView) -> UIView?
    {
        return popupController.dropShadowViewFor(view)
    }
    
    private var popupContentViewTopInset: CGFloat
    {
#if targetEnvironment(macCatalyst)
        return 10.0
#else
        if self.popupController.isContainerPresentationSheet {
            return 0.0
        }
        return UIDevice.current.userInterfaceIdiom == .pad ? 10.0 : 10.0
#endif
    }
    
    private var statusBarFrame: CGRect
    {
        var frame = self.popupController.statusBarFrame(for: self.popupController.containerViewController.view)
        if self.popupPresentationStyle == .deck, frame.height == 0 {
            let height = self.presentingVC.view.safeAreaInsets.top
            frame.size.height = height > 0 ? height : 20 // probably an old iPhone
        }
        if self.popupController.isContainerPresentationSheet {
            frame.size.height = 0.0
        }
        return frame
    }
        
    internal var popupBarForPresentation: UIView!
    
    internal var imageViewForPresentation: PBPopupRoundShadowImageView?
    
    private var bottomModuleFrameForPopupStateOpen: CGRect = .zero
    
    private var dimmerView: PBPopupDimmerView! = {
        let view = PBPopupDimmerView()
        view.autoresizingMask = []
        view.backgroundColor = UIColor.black
        view.alpha = 0.0
        view.clipsToBounds = true
        return view
    }()
    
    private var blackView: PBPopupBlackView! = {
        let view = PBPopupBlackView()
        view.autoresizingMask = []
        view.backgroundColor = UIColor.black
        view.alpha = 1.0
        view.clipsToBounds = true
        return view
    }()
    
    private var popupBarView: _PBPopupBarView!
    {
        return popupController.popupBarView
    }
    
    private var popupIsFloating: Bool {
        if self.popupContentView.popupPresentationStyle == .popup {
            return self.popupContentView.isFloating
        }
        else {
            let isFloating = self.popupContentView.isFloating || self.presentingVC.popupBar.isFloating || self.presentingVC.popupBar.popupBarWidth < self.presentingVC.defaultFrameForBottomBar().size.width || self.popupContentView.isFloating
            return isFloating
        }
    }
    
    private var touchForwardingView: PBTouchForwardingView!
    
    private class PBTouchForwardingView: UIView
    {
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
                    // The popup content has a popup open. Close it before closing the main popup content.
                    /*
                    if let popupController =  UIViewController.getAssociatedPopupControllerFor(self.popupController.containerViewController.popupContentViewController) {
                        if popupController.popupPresentationState == .open {
                            popupController.closePopupContent(animated: false) {
                                if self.popupController.containerViewController.popupContentView.popupCanDismissOnPassthroughViews {
                                    if self.popupController.popupPresentationState == .open {
                                        self.popupController.closePopupContent()
                                    }
                                }
                            }
                        }
                        break
                    }
                    */
                    // Close the poup content.
                    if popupController.containerViewController.popupContentView.popupCanDismissOnPassthroughViews {
                        if popupController.popupPresentationState == .open {
                            popupController.closePopupContent()
                        }
                    }
                    return nil
                }
            }
            return self
        }
    }
    
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?)
    {
        self.presentingVC = presentingViewController
        
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    }
    
    deinit
    {
        PBLog("deinit \(self)")
    }
    
    // MARK: - UIPresentationController
    
    override var shouldPresentInFullscreen: Bool {
        if self.presentingVC.popupContentView.popupPresentationStyle == .popup {
            return false
        }
        return true
    }

    override var frameOfPresentedViewInContainerView: CGRect
    {
        return self.presentedViewFrameForPopupStateOpen()
    }
    
    override func containerViewWillLayoutSubviews()
    {
        super.containerViewWillLayoutSubviews()
        
        self.popupContentView.frame = self.popupContentViewFrameForPopupStateOpen()
        self.presentedView?.frame = self.frameOfPresentedViewInContainerView

        self.containerView?.layoutIfNeeded()
    }
    
    override func containerViewDidLayoutSubviews()
    {
        super.containerViewDidLayoutSubviews()

        self.containerView?.frame = self.popupContainerViewFrame()

        self.containerView?.layoutIfNeeded()
    }
    
    override func presentationTransitionWillBegin()
    {
        guard let presentedView = self.presentedView,
              let containerView = self.containerView,
              let coordinator = self.presentedViewController.transitionCoordinator
        else {
            return
        }
        
        containerView.clipsToBounds = true
        containerView.frame = self.popupContainerViewFrame()
        
        let frame = containerView.bounds
        
        self.touchForwardingView = PBTouchForwardingView(frame: frame)
        self.touchForwardingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.touchForwardingView.passthroughViews = [self.presentingVC.view]
        self.touchForwardingView.popupController = self.popupController
        containerView.insertSubview(touchForwardingView, at: 0)
        
        self.shouldUpdateBackingView = false
        
        self.setupBackingView()
        
        self.popupContentView.contentView.addSubview(presentedView)
        self.popupContentView.contentView.sendSubviewToBack(presentedView)
        
        self.popupContentView.isHidden = true
        containerView.addSubview(self.popupContentView)
        
        if self.popupContentView.popupPresentationStyle != .popup {
            self.popupBarForPresentation = self.setupPopupBarForPresentation()
            if let popupBarForPresentation = self.popupBarForPresentation {
                self.popupContentView.contentView.addSubview(popupBarForPresentation)
                popupBarForPresentation.alpha = 1.0
            }
            
            self.imageViewForPresentation = self.setupImageViewForPresentation()
            if let imageViewForPresentation = self.imageViewForPresentation {
                self.popupContentView.contentView.addSubview(imageViewForPresentation)
                self.configureImageViewInStartPosition()
            }
        }
                
        self.popupContentView.popupCloseButton?.alpha = 0.0
        self.popupContentView.popupCloseButton?.setButtonStateStationary()
        
        self.setupCornerRadiusForPopupContentViewAnimated(false, open: false)
        
        if !coordinator.isInteractive {
            self.popupController.popupStatusBarStyle = self.popupController.popupPreferredStatusBarStyle
        }

        coordinator.animate {context in
            self.presentingVC.setNeedsStatusBarAppearanceUpdate()
            self.animateBackingViewToDeck(true, animated: true)
            self.animateImageViewInFinalPosition()
            
            self.setupCornerRadiusForPopupContentViewAnimated(true, open: true)
            
            if !context.isInteractive {
                self.popupBarForPresentation?.alpha = 0.0
                self.popupContentView.popupCloseButton?.alpha = 1.0
            }
            self.popupContentView.updatePopupCloseButtonPosition()

            containerView.layoutIfNeeded()
        } completion: { _ in
            self.popupContentView.popupImageView?.isHidden = false
            self.popupContentView.popupImageModule?.isHidden = false
        }
    }
    
    override func presentationTransitionDidEnd(_ completed: Bool)
    {
        // Issue #23 - Reset the corner radius for the aesthetics of the animation of the control center presentation when state is open.
        let defaultCornerRadius = self.popupController.cornerRadiusForWindow()
        if defaultCornerRadius > 0 {
            let isFullScreen = self.popupContentView.popupContentSize.height == UIScreen.main.bounds.height
            if self.popupPresentationStyle == .fullScreen && !self.popupController.isContainerPresentationSheet ||  (self.popupPresentationStyle == .custom && isFullScreen) {
                self.setupCornerRadiusForPopupContentViewAnimated(false, open: false)
            }
        }
        //
        self.popupBarForPresentation?.removeFromSuperview()
        self.popupBarForPresentation = nil
        self.imageViewForPresentation?.removeFromSuperview()
        self.imageViewForPresentation = nil
        if !completed {
            self.cleanup()
        }
        else {
            self.blackView?.alpha = 1.0
            NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground(_:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
        }
        self.shouldUpdateBackingView = true
    }
    
    override func dismissalTransitionWillBegin()
    {
        guard let coordinator = self.presentedViewController.transitionCoordinator,
              let containerView = self.containerView
        else {
            return
        }
        
        if self.popupContentView.popupPresentationStyle != .popup {
            self.popupBarForPresentation = self.setupPopupBarForPresentation()
            if let popupBarForPresentation = self.popupBarForPresentation {
                self.popupContentView.contentView.addSubview(popupBarForPresentation)
                popupBarForPresentation.alpha = 0.0
            }
            
            self.imageViewForPresentation = self.setupImageViewForPresentation()
            if let imageViewForPresentation = self.imageViewForPresentation {
                self.popupContentView.contentView.addSubview(imageViewForPresentation)
                self.configureImageViewInStartPosition()
            }
        }
        
        self.shouldUpdateBackingView = false
        
        if let backingView = self.backingView {
            backingView.removeFromSuperview()
        }
        self.backingView = nil
        self.setupBackingView()
        self.animateBackingViewToDeck(true, animated: false)
        
        self.popupContentView.popupCloseButton?.setButtonStateTransitioning()
        
        // Issue #23
        self.setupCornerRadiusForPopupContentViewAnimated(false, open: true)
        //
        
        if !coordinator.isInteractive {
            self.popupController.popupStatusBarStyle = self.popupController.containerPreferredStatusBarStyle
        }
        
        coordinator.animate { context in
            self.presentingVC.setNeedsStatusBarAppearanceUpdate()
            self.animateBackingViewToDeck(false, animated: true)
            if !context.isInteractive {
                self.animateImageViewInFinalPosition()
                self.popupBarForPresentation?.alpha = 1.0
                self.popupContentView.popupCloseButton?.alpha = 0.0
            }
            
            self.setupCornerRadiusForPopupContentViewAnimated(true, open: false)
    
            containerView.layoutIfNeeded()
        } completion: { _ in
            self.popupContentView.popupImageView?.isHidden = false
            self.popupContentView.popupImageModule?.isHidden = false
        }
    }
    
    internal func continueDismissalAnimationWithDurationFactor(_ durationFactor: CGFloat)
    {
        if let animator = self.animator {
            animator.stopAnimation(false)

            self.finishAnimator = UIViewPropertyAnimator(duration: animator.duration * Double(durationFactor), dampingRatio: 1, animations: {
                self.popupContentView.frame = self.popupContentViewFrameForPopupStateClosed(finish: true, isInteractive: true)
                self.presentedView?.frame = self.presentedViewFrameForPopupStateClosed()
                self.animateBottomBarToHidden(false)
                self.animateBackingViewToDeck(false, animated: true)
                self.animateImageViewInFinalPosition()
                self.setupCornerRadiusForPopupContentViewAnimated(true, open: false)
                self.popupContentView.popupCloseButton?.alpha = 0.0
                self.popupBarForPresentation?.alpha = 1.0
            })
            
            self.finishAnimator.addCompletion { (_) in
                animator.finishAnimation(at: .end)
            }
            
            self.finishAnimator.startAnimation()
        }
    }

    override func dismissalTransitionDidEnd(_ completed: Bool)
    {
        self.popupBarForPresentation?.removeFromSuperview()
        self.popupBarForPresentation = nil
        self.imageViewForPresentation?.removeFromSuperview()
        self.imageViewForPresentation = nil
        
        // Issue #23
        let defaultCornerRadius = self.popupController.cornerRadiusForWindow()
        if defaultCornerRadius > 0 {
            let isFullScreen = self.popupContentView.popupContentSize.height == UIScreen.main.bounds.height
            if self.popupPresentationStyle == .fullScreen || (self.popupPresentationStyle == .custom && isFullScreen) {
                self.setupCornerRadiusForPopupContentViewAnimated(false, open: false)
            }
        }
        //
        if completed {
            self.cleanup()
        }
        else {
            self.blackView?.alpha = 1.0
        }
        self.shouldUpdateBackingView = true
    }
    
    @objc func didEnterBackground(_ sender: Any)
    {
        self.shouldUpdateBackingView = false
        delay(2) {
            self.shouldUpdateBackingView = true
        }
    }
    
    private func cleanup()
    {
        self.backingView?.removeFromSuperview()
        self.backingView = nil
        
        self.blackView?.removeFromSuperview()
        self.dimmerView?.removeFromSuperview()
        
        self.touchForwardingView.removeFromSuperview()
        self.touchForwardingView = nil
        
        self.presentedView?.removeFromSuperview()
        self.popupContentView.removeFromSuperview()
    }
}

// MARK: - UIViewControllerAnimatedTransitioning

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
        let presentedView = transitionContext.view(forKey: self.isPresenting ? .to : .from)
        
        var animator: UIViewPropertyAnimator!
        
        self.containerView?.layoutIfNeeded()

        if self.isPresenting {
            if self.popupContentView.popupPresentationStyle == .popup {
                self.popupContentView.frame = self.popupContentViewFrameForPopupStateHidden(finish: false)
                presentedView?.frame = self.presentedViewFrameForPopupStateHidden()
            }
            else {
                self.popupContentView.frame = self.popupContentViewFrameForPopupStateClosed(finish: false)
                presentedView?.frame = self.presentedViewFrameForPopupStateClosed()
            }
            
            self.popupContentView.isHidden = false
            
            self.configureBottomModuleInStartPosition()
            
            let animations = {
                self.popupContentView.frame = self.popupContentViewFrameForPopupStateOpen()
                presentedView?.frame = self.presentedViewFrameForPopupStateOpen()

                self.popupBarForPresentation?.center.x = self.popupContentView.contentView.center.x

                self.animateBottomBarToHidden(true)
                
                self.animateBottomModuleInFinalPosition()

                self.containerView?.layoutIfNeeded()
            }

            let completion: (() -> Void) = {() -> Void in
                if transitionContext.transitionWasCancelled {
                    // Restore the initial frame after cancel presenting
                    self.configureBottomModuleInOriginalPosition()
                }
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
            
            animator = UIViewPropertyAnimator(duration: self.transitionDuration(using: transitionContext), dampingRatio: 1, animations: {
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
            
            self.animateBottomBarToHidden(true)
            
            let animations = {
                if self.popupContentView.popupPresentationStyle == .popup {
                    self.popupContentView.frame = self.popupContentViewFrameForPopupStateHidden(finish: false, isInteractive: transitionContext.isInteractive)
                    presentedView?.frame = self.presentedViewFrameForPopupStateHidden()
                }
                else {
                    self.popupContentView.frame = self.popupContentViewFrameForPopupStateClosed(finish: false, isInteractive: transitionContext.isInteractive)
                    presentedView?.frame = self.presentedViewFrameForPopupStateClosed()
                }

                if !transitionContext.isInteractive {
                    self.animateBottomBarToHidden(false)
                }
                self.containerView?.layoutIfNeeded()
            }

            let completion = {
                // Restore the initial frame after dismiss
                self.configureBottomModuleInOriginalPosition()
                
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }

            animator = UIViewPropertyAnimator(duration: self.transitionDuration(using: transitionContext), dampingRatio: 1, animations: {
                animations()
            })
            animator.addCompletion { (_) in
                completion()
            }
        }
        
        if transitionContext.isInteractive {
            animator.startAnimation()
            animator.pauseAnimation()
        }
        
        self.animator = animator
        return animator
    }
    
    func animationEnded(_ transitionCompleted: Bool)
    {
        self.animator = nil
    }
    
    // MARK: - User Interface Style & Size
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?)
    {
        super.traitCollectionDidChange(previousTraitCollection)
        guard previousTraitCollection != nil, let backingView = self.backingView, self.shouldUpdateBackingView == true else { return }
        if self.traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle {
            backingView.removeFromSuperview()
            self.backingView = nil
            self.setupBackingView()
            self.animateBackingViewToDeck(true, animated: false)
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator)
    {
        super.viewWillTransition(to: size, with: coordinator)
        
        if let backingView = self.backingView {
            backingView.removeFromSuperview()
            self.backingView = nil
        }
        
        self.containerView?.layoutIfNeeded()
        coordinator.animate(alongsideTransition: { (context) in
            self.containerView?.frame = self.popupContainerViewFrame()
            self.blackView?.frame = self.popupBlackViewFrame()
            self.setupBackingView()
            self.animateBackingViewToDeck(true, animated: false)
            self.popupContentView.frame = self.popupContentViewFrameForPopupStateOpen()
            self.setupCornerRadiusForPopupContentViewAnimated(true, open: true)
            self.popupContentView.updatePopupCloseButtonPosition()
            self.containerView?.layoutIfNeeded()
        })
    }
}

// MARK: - Frames

extension PBPopupPresentationController
{
    private func popupContainerViewFrame() -> CGRect
    {
        var frame = self.presentingVC.view.frame
        if self.shouldPresentInFullscreen == true {
            if let dropShadowView = self.dropShadowViewFor(self.presentingVC.view) {
                frame = dropShadowView.frame
                frame.origin.x += self.presentingVC.view.frame.minX
                frame.size.width = self.presentingVC.view.frame.width
            }
        }
        PBLog("\(frame)")
        return frame
    }
    
    /// Bottom above the tabBar
    private func popupBlackViewFrame() -> CGRect
    {
        var frame: CGRect = .zero
        if let dropShadowView = self.dropShadowViewFor(self.presentingVC.view) {
            frame = dropShadowView.bounds
        }
        else {
            frame = self.popupContentViewFrameForPopupStateOpen()
            frame.origin.y = 0
        }
        let popupBarViewFrame = self.popupController.popupBarViewFrameForPopupStateClosed()
        let isFloating = self.popupIsFloating
        frame.size.height = self.isPresenting ? popupBarViewFrame.maxY + (isFloating ? self.presentingVC.defaultFrameForBottomBar().size.height : 0.0) : (isFloating ? popupBarViewFrame.maxY  + (isFloating ? self.presentingVC.defaultFrameForBottomBar().size.height : 0.0) : popupBarViewFrame.maxY)
        if let nc = self.presentingVC as? UINavigationController, nc.isToolbarHidden == false {
            let insets = self.presentingVC.insetsForBottomBar()
            frame.size.height += isFloating ? insets.bottom : 0.0
        }
        PBLog("\(frame)")
        return frame
    }
    
    private func dimmerViewFrame() -> CGRect
    {
        guard let containerView = self.containerView else { return .zero }
        
        var frame: CGRect = .zero
        frame = containerView.bounds
        self.dimmerView.frame.origin.x = self.popupContentViewFrameForPopupStateOpen().minX
        self.dimmerView.frame.size.width = self.popupContentViewFrameForPopupStateOpen().width
        PBLog("\(frame)")
        return frame
    }
    
    internal func popupContentViewFrameForPopupStateHidden(finish: Bool, isInteractive: Bool = false) -> CGRect
    {
        guard let containerView = self.containerView else { return .zero }
        
        var frame = self.presentingVC.defaultFrameForBottomBar()

        var width = frame.size.width
        if let dropShadowView = self.dropShadowViewFor(self.presentingVC.view) {
            width = dropShadowView.frame.width
        }
        var height = containerView.bounds.height

        let y = height
        let x = (width - self.popupContentView.popupContentSize.width) / 2
        
        width = self.popupContentView.popupContentSize.width
        height = self.popupContentView.popupContentSize.height
        
        frame = CGRect(x: x, y: y, width: width, height: height)
        PBLog("\(frame)")
        return frame
    }
    
    private func presentedViewFrameForPopupStateHidden() -> CGRect
    {
        var frame = self.popupContentViewFrameForPopupStateHidden(finish: false)
        frame.origin.x = 0
        frame.origin.y = 0
        frame.size.height = self.popupContentViewFrameForPopupStateOpen().height
        frame.size.width = self.popupContentViewFrameForPopupStateOpen().width
        PBLog("\(frame)")
        return frame
    }
    
    internal func popupContentViewFrameForPopupStateClosed(finish: Bool, isInteractive: Bool = false) -> CGRect
    {
        var frame: CGRect = .zero
        if !self.isPresenting && isInteractive && !finish {
            frame = self.presentingVC.defaultFrameForBottomBar()
            frame.origin.x = self.popupController.popupBarViewFrameForPopupStateClosed().origin.x
            frame.size.width = self.popupController.popupBarViewFrameForPopupStateClosed().width
        }
        else {
            frame = self.popupController.popupBarViewFrameForPopupStateClosed()
            if self.presentingVC.popupBar.isFloating {
                frame = frame.inset(by: self.presentingVC.popupBar.floatingInsets)
                if self.presentingVC.defaultFrameForBottomBar().height == 0 || self.presentingVC.bottomBar.isHidden {
                    let insets = UIEdgeInsets(top: 0, left: 0, bottom: self.presentingVC.insetsForBottomBar().bottom, right: 0)
                    frame = frame.inset(by: insets)
                }
            }
        }
        PBLog("\(frame)")
        return frame
    }
    
    private func presentedViewFrameForPopupStateClosed() -> CGRect
    {
        var frame = self.popupContentViewFrameForPopupStateClosed(finish: false)
        frame.origin.x = 0
        frame.origin.y = 0
        frame.size.height = self.popupContentViewFrameForPopupStateOpen().height
        frame.size.width = self.popupContentViewFrameForPopupStateOpen().width
        PBLog("\(frame)")
        return frame
    }
    
    internal func popupContentViewFrameForPopupStateOpen() -> CGRect
    {
        guard let containerView = self.containerView else { return .zero }
        
        var x: CGFloat = self.presentingVC.defaultFrameForBottomBar().origin.x
        var y: CGFloat = 0.0

        var width = self.presentingVC.defaultFrameForBottomBar().size.width
        var height = containerView.bounds.height

        /*
#if targetEnvironment(macCatalyst)
        if self.popupPresentationStyle == .fullScreen {
            //y = self.statusBarFrame.height
        }
#endif
        */
        
        if self.popupPresentationStyle != .fullScreen {
            y = self.isCompactOrPhoneInLandscape() ? 0.0 : self.statusBarFrame.height + self.popupContentViewTopInset
            width = self.presentingVC.defaultFrameForBottomBar().size.width
            if self.popupPresentationStyle == .custom || self.popupPresentationStyle == .popup {
                y = height - self.popupContentView.popupContentSize.height
                if self.popupContentView.popupContentSize.width > 0 {
                    width = self.presentingVC.view.bounds.width
                    x = (width - self.popupContentView.popupContentSize.width) / 2
                    width = self.popupContentView.popupContentSize.width
                }
            }
            height = height - y
        }
        var frame = CGRect(x: x, y: y, width: width, height: height)
        
        let vc = self.presentingVC!
        if vc is UINavigationController || vc is UITabBarController {
            frame = CGRect(x: max(0.0, x), y: y, width: min(containerView.bounds.width, width), height: height)
            if let svc = vc.splitViewController, vc === svc.viewControllers.first {
                frame.origin.x += abs(vc.view.frame.minX)
                frame.size.width -= abs(vc.view.frame.minX)
            }

            if #available(iOS 14, *) {
                if UIDevice.current.userInterfaceIdiom == .pad, let svc = self.presentingVC.splitViewController, self.dropShadowViewFor(svc.view) != nil {
                    let x = self.presentingVC.view.safeAreaInsets.left
                    frame = CGRect(x: x, y: y, width: containerView.bounds.width - x, height: height)
                }
            }
        }
        if self.popupContentView.isFloating {
            if self.presentingVC.defaultFrameForBottomBar().height == 0 || self.presentingVC.bottomBar.isHidden {
                frame.origin.y -= self.presentingVC.view.safeAreaInsets.bottom
            }
            frame.origin.y -= (self.presentingVC.defaultFrameForBottomBar().height + self.popupContentView.additionalFloatingBottomInset)
        }
        PBLog("\(frame)")
        return frame
    }
    
    private func presentedViewFrameForPopupStateOpen() -> CGRect
    {
        var frame = self.popupContentViewFrameForPopupStateOpen()
        frame.origin.x = 0
        frame.origin.y = 0
        PBLog("\(frame)")
        return frame
    }
    
    // MARK: - Corner radii
    
    internal func setupCornerRadiusForDimmerView()
    {
        if let dropShadowView = self.dropShadowViewFor(self.presentingVC.view) {
            self.dimmerView.layer.cornerRadius = dropShadowView.layer.cornerRadius
            if let svc = self.presentingVC.splitViewController, self.traitCollection.horizontalSizeClass == .regular {
                if svc.viewControllers.firstIndex(of: self.presentingVC) == 0 {
                    self.dimmerView.frame.origin.x = self.popupContentViewFrameForPopupStateOpen().minX
                    self.dimmerView.frame.size.width = self.popupContentViewFrameForPopupStateOpen().width
                    self.dimmerView.layer.maskedCorners = [.layerMinXMinYCorner]
                }
                else if svc.viewControllers.firstIndex(of: self.presentingVC) == 1 {
                    self.dimmerView.layer.maskedCorners = [.layerMaxXMinYCorner]
                }
            }
            self.dimmerView.layer.cornerCurve = dropShadowView.layer.cornerCurve
        }
    }
    
    internal func setupCornerRadiusForBackingViewAnimated(_ animated: Bool, open: Bool)
    {
        guard let backingView = self.backingView else { return }
        
        let defaultCornerRadius = self.popupController.cornerRadiusForWindow()
        
        var cornerRadius: CGFloat = 0.0
//#if targetEnvironment(macCatalyst)
//        cornerRadius = defaultCornerRadius
//#else
        cornerRadius = open ? 10.0 : defaultCornerRadius
//#endif
        backingView.layer.cornerCurve = .continuous
        
        if !self.popupIsFloating {
            backingView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
        else {
            if !self.isPresenting {
                backingView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            }
        }
        backingView.layer.cornerRadius = cornerRadius
    }
    
    internal func setupCornerRadiusForPopupContentViewAnimated(_ animated: Bool, open: Bool)
    {
        let defaultCornerRadius = self.popupController.cornerRadiusForWindow()
        
        var cornerRadius: CGFloat = 0.0
//#if targetEnvironment(macCatalyst)
//        cornerRadius = defaultCornerRadius
//#else
        
        let isFloating = self.popupIsFloating
        var floatingRadius: CGFloat = 0.0
        if self.presentingVC.popupContentView.popupPresentationStyle == .popup {
            floatingRadius = 10.0
        }
        else {
            floatingRadius = self.presentingVC.popupBar.floatingRadius
        }

        switch self.popupPresentationStyle {
        case .deck:
            cornerRadius = open ? (self.isCompactOrPhoneInLandscape() ? defaultCornerRadius : 10.0) : isFloating ? floatingRadius : 0.0
        case .custom:
            let isFullScreen = self.popupContentView.popupContentSize.height == UIScreen.main.bounds.height
            if isFullScreen {
                cornerRadius = open ? defaultCornerRadius : isFloating ? floatingRadius : 0.0
            }
            else {
                cornerRadius = open ? 10.0 : isFloating ? floatingRadius : 0.0
            }
        case .fullScreen:
            cornerRadius = open ? defaultCornerRadius : isFloating ? floatingRadius : 0.0
        case .popup:
            cornerRadius = isFloating ? floatingRadius : 0.0
        }
        self.popupContentView.layer.cornerCurve = .continuous
        
#if !targetEnvironment(macCatalyst)
        if self.popupContentView.popupPresentationStyle != .popup {
            if let dropShadowView = self.popupController.dropShadowViewFor(self.presentingVC.view) {
                cornerRadius = open ? dropShadowView.layer.cornerRadius : isFloating ? floatingRadius : 0.0
                self.popupContentView.layer.cornerCurve = dropShadowView.layer.cornerCurve
            }
        }
#endif
//#endif
        self.popupContentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]

        /// splitViewController master or detail
        if let svc = self.presentingVC.splitViewController, self.traitCollection.horizontalSizeClass == .regular {
            // Master
            if svc.viewControllers.firstIndex(of: self.presentingVC) == 0 {
                if !isFloating {
                    self.popupContentView.layer.maskedCorners = [.layerMinXMinYCorner]
                }
            }
            // Detail
            else if svc.viewControllers.firstIndex(of: self.presentingVC) == 1 {
                if !isFloating {
                    self.popupContentView.layer.maskedCorners = [.layerMaxXMinYCorner]
                }
            }
            if self.popupPresentationStyle == .custom || self.popupPresentationStyle == .popup {
                if !isFloating {
                    self.popupContentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                }
            }
        }
        else {
            if UIDevice.current.userInterfaceIdiom == .phone {
                if !isFloating {
                    self.popupContentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                }
            }
            else {
                if !self.popupController.isContainerPresentationSheet {
                    if !isFloating {
                        self.popupContentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                    }
                }
            }
        }
        self.popupContentView.layer.cornerRadius = cornerRadius
    }
    
    
    // MARK: - Snapshot views
    
    private func setupBackingView()
    {
        guard let containerView = self.containerView else { return }
        
        if self.popupPresentationStyle == .custom || self.popupPresentationStyle == .popup || self.popupController.isContainerPresentationSheet || self.presentingVC.splitViewController != nil {
            self.dimmerView.frame = self.dimmerViewFrame()
            self.setupCornerRadiusForDimmerView()
            if self.popupContentView.wantsPopupDimmerView {
                containerView.addSubview(self.dimmerView)
                containerView.sendSubviewToBack(self.dimmerView)
            }
            return
        }

        if self.backingView == nil {
            let isHidden = self.popupBarView.isHidden
            let isFloating = self.popupIsFloating
            if !isFloating {
                self.popupBarView.isHidden = true
            }

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
            self.backingView = snapshotView.resizableSnapshotView(from: imageRect, afterScreenUpdates: self.isPresenting ? false : true, withCapInsets: .zero)
            self.backingView.autoresizingMask = []
            
            if !isFloating {
                self.popupBarView.isHidden = isHidden
            }

            self.backingView.frame = imageRect
            
            self.backingView.clipsToBounds = true
            
            self.setupCornerRadiusForBackingViewAnimated(false, open: false)
            
            self.dimmerView.backgroundColor = self.traitCollection.userInterfaceStyle == .light ? .black : .lightGray
            
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
        if deck == true {
            self.dimmerView.alpha = 0.2
            if self.presentingVC.splitViewController != nil { return }
            
            if self.popupPresentationStyle != .custom && self.popupPresentationStyle != .popup {
                let scaledXY = (self.presentingVC.view.bounds.width - self.presentingVC.view.layoutMargins.right * 2) / self.presentingVC.view.bounds.width
                
                if let dropShadowView = self.dropShadowViewFor(self.presentingVC.view) {
                    
                    if self.popupPresentationStyle == .fullScreen { return }
                    
                    let translatedY = dropShadowView.superview!.bounds.height * ((1 - scaledXY) / 2) + 10
                    dropShadowView.superview?.transform = CGAffineTransform(a: scaledXY, b: 0.0, c: 0.0, d: scaledXY, tx: 1.0, ty: -translatedY)
                }
                else {
                    self.backingView.transform = .identity
                    let translatedY = self.statusBarFrame.height - (self.statusBarFrame.height > 0 ? (self.backingView.bounds.height * (1 - scaledXY) / 2) : 0.0)
                    self.backingView.transform = CGAffineTransform(a: scaledXY, b: 0.0, c: 0.0, d: scaledXY, tx: 1.0, ty: translatedY)
                    self.setupCornerRadiusForBackingViewAnimated(animated, open: true)
                }
            }
        }
        else {
            self.dimmerView.alpha = 0.0
            if self.presentingVC.splitViewController != nil { return }
            if let dropShadowView = self.dropShadowViewFor(self.presentingVC.view) {
                dropShadowView.superview?.transform = .identity
            }
            else {
                self.setupCornerRadiusForBackingViewAnimated(animated, open: false)
                if let backingView = self.backingView {
                    backingView.transform = .identity
                }
            }
        }
    }
    
    private func setupPopupBarForPresentation() -> UIView?
    {
        let alpha = self.popupBarView.alpha
        self.popupBarView.alpha = 1.0
        
        guard let popupBar = self.presentingVC.popupBar else { return nil }
        
        if !self.isCompactOrPhoneInLandscape() && self.popupContentView.popupImageView != nil {
            popupBar.shadowImageView.isHidden = true
        }
        
        let isFloating = popupBar.isFloating
        
        var rect = self.popupContentViewFrameForPopupStateClosed(finish: true)
        
        if !isFloating, self.presentingVC.splitViewController != nil {
            rect.origin.x = self.popupContentViewFrameForPopupStateOpen().minX
            rect.size.width = self.popupContentViewFrameForPopupStateOpen().width
        }
        
        //for debug
        //let image = self.presentingVC.view.makeSnapshot(from: rect)
        
        let view = self.presentingVC.view.resizableSnapshotView(from: rect, afterScreenUpdates: true, withCapInsets: .zero)
        
        if popupBar.popupBarStyle == .prominent {
            self.presentingVC.popupBar.shadowImageView.isHidden = false
        }
        
        self.popupBarView.alpha = alpha

        if isFloating, let view = view {
            view.clipsToBounds = true
            view.layer.cornerCurve = .continuous
            view.layer.cornerRadius = popupBar.floatingRadius
        }
        
        //PBLog("view: \(String(describing: view))")
        return view
    }
    
    // MARK: - Bottom bar
    
    private func animateBottomBarToHidden( _ hidden: Bool)
    {
        let isFloating = self.popupIsFloating
        if !isFloating {
            self.presentingVC._animateBottomBarToHidden(hidden)
        }
    }
    
    // MARK: - Image view
    
    private func setupImageViewForPresentation() -> PBPopupRoundShadowImageView?
    {
        if self.isCompactOrPhoneInLandscape() {return nil}
        
        if self.presentingVC.popupBar.popupBarStyle == .prominent, let imageView = self.popupContentView.popupImageView, let shadowImageView = self.presentingVC.popupBar.shadowImageView  {
            
            let moduleView = PBPopupRoundShadowImageView(frame: .zero)

            moduleView.image = imageView.image

            if self.isPresenting {
                moduleView.imageView.backgroundColor = shadowImageView.backgroundColor
                moduleView.imageView.contentMode = shadowImageView.contentMode
                moduleView.imageView.clipsToBounds = shadowImageView.clipsToBounds
                moduleView.imageView.layer.cornerRadius = shadowImageView.layer.cornerRadius

                moduleView.clipsToBounds = shadowImageView.clipsToBounds
                moduleView.cornerRadius = shadowImageView.cornerRadius
                moduleView.shadowColor = shadowImageView.shadowColor
                moduleView.shadowOpacity = shadowImageView.shadowOpacity
                moduleView.shadowOffset = shadowImageView.shadowOffset
                moduleView.shadowRadius = shadowImageView.shadowRadius
            }
            else {
                moduleView.imageView.backgroundColor = imageView.backgroundColor
                moduleView.imageView.contentMode = imageView.contentMode
                moduleView.imageView.clipsToBounds = imageView.clipsToBounds
                moduleView.cornerRadius = imageView.layer.cornerRadius

                if let imageModule = self.popupContentView.popupImageModule {
                    moduleView.clipsToBounds = imageModule.clipsToBounds
                    moduleView.shadowColor = UIColor(cgColor: imageModule.layer.shadowColor ?? UIColor.black.cgColor)
                    moduleView.shadowOpacity = imageModule.layer.shadowOpacity
                    moduleView.shadowOffset = imageModule.layer.shadowOffset
                    moduleView.shadowRadius = imageModule.layer.shadowRadius
                }
            }
            return moduleView
        }
        return nil
    }
    
    private func configureImageViewInStartPosition()
    {
        if self.isCompactOrPhoneInLandscape() {return}
        
        guard let presentedView = self.presentedView else { return }
        guard let popupBar = UIViewController.getAssociatedPopupBarFor(self.presentingVC) else { return }
        guard popupBar.popupBarStyle == .prominent else { return }
        guard let imageViewForPresentation = self.imageViewForPresentation else { return }
        guard let imageView = self.popupContentView.popupImageView else { return }
        
        if self.isPresenting {
            var closedFrame = popupBar.shadowImageView.frame

            closedFrame.origin.x -= self.popupContentViewFrameForPopupStateOpen().minX
            if closedFrame.origin.x < 0 {
                closedFrame.origin.x = popupBar.shadowImageView.frame.minX
            }
            
            imageViewForPresentation.frame = closedFrame
        }
        else {
            let openFrame = imageView.convert(imageView.bounds, to: presentedView)
            imageViewForPresentation.frame = openFrame
        }
        imageView.isHidden = true
        self.popupContentView.popupImageModule?.isHidden = true
    }
    
    internal func animateImageViewInFinalPosition()
    {
        if self.isCompactOrPhoneInLandscape() {return}
        
        guard let presentedView = self.presentedView else { return }
        guard let popupBar = UIViewController.getAssociatedPopupBarFor(self.presentingVC) else { return }
        guard popupBar.popupBarStyle == .prominent else { return }
        guard let imageViewForPresentation = self.imageViewForPresentation else { return }
        guard let imageView = self.popupContentView.popupImageView else { return }
        guard let shadowImageView = popupBar.shadowImageView else { return }
        
        if self.isPresenting {
            let openFrame = imageView.convert(imageView.bounds, to: presentedView)
            imageViewForPresentation.frame = openFrame
            if imageView.layer.cornerRadius > 0 {
                imageViewForPresentation.cornerRadius = imageView.layer.cornerRadius
            }
            imageViewForPresentation.imageView.backgroundColor = imageView.backgroundColor
            imageViewForPresentation.imageView.contentMode = imageView.contentMode
            imageViewForPresentation.imageView.clipsToBounds = imageView.clipsToBounds
            
            if let imageModule = self.popupContentView.popupImageModule {
                imageViewForPresentation.clipsToBounds = imageModule.clipsToBounds
                imageViewForPresentation.shadowColor = UIColor(cgColor: imageModule.layer.shadowColor ?? UIColor.black.cgColor)
                imageViewForPresentation.shadowOpacity = imageModule.layer.shadowOpacity
                imageViewForPresentation.shadowOffset = imageModule.layer.shadowOffset
                imageViewForPresentation.shadowRadius = imageModule.layer.shadowRadius
            }
        }
        else {
            var closedFrame = popupBar.shadowImageView.frame
            
            closedFrame.origin.x -= self.popupContentViewFrameForPopupStateOpen().minX
            if closedFrame.origin.x < 0 {
                closedFrame.origin.x = popupBar.shadowImageView.frame.minX
            }
            
            imageViewForPresentation.frame = closedFrame
            imageViewForPresentation.cornerRadius = shadowImageView.cornerRadius
            imageViewForPresentation.imageView.backgroundColor = shadowImageView.backgroundColor
            imageViewForPresentation.imageView.contentMode = shadowImageView.contentMode
            imageViewForPresentation.imageView.clipsToBounds = shadowImageView.imageView.clipsToBounds
            
            imageViewForPresentation.clipsToBounds = shadowImageView.clipsToBounds
            imageViewForPresentation.shadowColor = shadowImageView.shadowColor
            imageViewForPresentation.shadowOpacity = shadowImageView.shadowOpacity
            if popupBar.imageShadowOpacity > 0.0 {
                imageViewForPresentation.shadowOpacity = popupBar.imageShadowOpacity
            }
            imageViewForPresentation.shadowOffset = shadowImageView.shadowOffset
            imageViewForPresentation.shadowRadius = shadowImageView.shadowRadius
        }
    }
    
    // MARK: - Bottom module
    
    private func configureBottomModuleInStartPosition()
    {
        guard let popupBar = UIViewController.getAssociatedPopupBarFor(self.presentingVC) else { return }
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
        guard let popupBar = UIViewController.getAssociatedPopupBarFor(self.presentingVC) else { return }
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
        guard let popupBar = UIViewController.getAssociatedPopupBarFor(self.presentingVC) else { return }
        guard popupBar.popupBarStyle == .prominent else { return }
        guard let bottomModule = self.popupContentView.popupBottomModule else { return }
        
        if self.bottomModuleFrameForPopupStateOpen != .zero {
            bottomModule.frame = self.bottomModuleFrameForPopupStateOpen
        }
    }
    
    // MARK: - Helpers
    
    private func isCompactOrPhoneInLandscape() -> Bool
    {
        if self.traitCollection.verticalSizeClass == .compact {return true}
        let orientation = self.popupController.statusBarOrientation(for: self.popupController.containerViewController.view)
        return UIDevice.current.userInterfaceIdiom == .phone && (orientation == .landscapeLeft || orientation == .landscapeRight)
    }
    
    private func isRegularSizeClass() -> Bool
    {
        let orientation = self.popupController.statusBarOrientation(for: self.popupController.containerViewController.view)
        if orientation == .landscapeLeft || orientation == .landscapeRight {
            return self.traitCollection.horizontalSizeClass == .regular
        }
        else {
            return self.traitCollection.verticalSizeClass == .regular
        }
    }

    private func delay(_ delay:Double, closure:@escaping ()->())
    {
        let when = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
    }
    
    private func _viewFor(_ view: UIView?, selfOrSuperviewKindOf aClass: AnyClass) -> UIView?
    {
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

// MARK: - Custom views

extension PBPopupPresentationController
{
    internal class PBPopupDimmerView: UIView {
        override init(frame: CGRect) {
            super.init(frame: frame)
        }
        
        required init(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

    internal class PBPopupBlackView: UIView {
        override init(frame: CGRect) {
            super.init(frame: frame)
        }
        
        required init(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
