//
//  PBPopupPresentationController.swift
//  PBPopupController
//
//  Created by Patrick BODET on 13/07/2018.
//  Copyright © 2018 Patrick BODET. All rights reserved.
//

import UIKit

internal class PBPopupPresentationController: UIPresentationController {
    
    // Hope I will find a better way.
    let hackForSplitViewController: Bool = true
    
    private var presentingVC: UIViewController!
    internal weak var popupController: PBPopupController!
    private var popupPresentationState: PBPopupPresentationState {
        return popupController.popupPresentationState
    }
    
    internal var backingView: UIView!

    internal var popupPresentationStyle = PBPopupPresentationStyle.deck
    internal var isPresenting = false
    
    private var popupContentView: PBPopupContentView! {
        return popupController.containerViewController.popupContentView
    }
    
    let popupContentViewTopInset: CGFloat = 8.0
    
    private var statusBarFrame: CGRect! {
        var frame = UIApplication.shared.statusBarFrame
        if presentedViewController.prefersStatusBarHidden {
            frame.size.height = 0.0
        }
        return frame
    }
    
    internal var popupBarForPresentation: UIView!

    internal var imageViewForPresentation: PBPopupRoundShadowImageView?

    private var controlsModuleTopConstraint: NSLayoutConstraint?
    private var controlsModuleTopConstant: CGFloat!
    private var controlsModuleBottomConstant: CGFloat!
    
    private var controlsModuleFrameForPopupStateOpen: CGRect = .zero

    private var dimmerView: UIView = {
        let view = UIView()
        view.autoresizingMask = []
        view.backgroundColor = UIColor.black
        view.alpha = 0.0
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
    
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        self.presentingVC = presentingViewController
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        get {
            var frame = CGRect.zero
            frame = self.popupContentViewFrameForPopupStateOpen()
            frame.origin.x = 0.0
            frame.origin.y = 0.0
            return frame
        }
    }
    
    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()

        let presentedView = self.presentedView!
        
        presentedView.setNeedsUpdateConstraints()
        presentedView.setNeedsLayout()
        presentedView.layoutIfNeeded()
        
        self.popupContentView.frame = self.popupContentViewFrameForPopupStateOpen()
        presentedView.frame = self.frameOfPresentedViewInContainerView
    }
    
    override func containerViewDidLayoutSubviews() {
        super.containerViewDidLayoutSubviews()
    }

    override func presentationTransitionWillBegin() {
        guard self.presentedView != nil else { return }
        guard let containerView = self.containerView else { return }
        guard let coordinator = self.presentedViewController.transitionCoordinator else { return }
        
        //presentingVC.beginAppearanceTransition(false, animated: true)

        containerView.frame = self.presentingVC.view.frame

        self.popupBarForPresentation = self.setupPopupBarForPresentation()
        
        //self.popupBarView.isHidden = true
        
        if self.popupPresentationStyle == .deck {
            
            self.blackView.frame = self.popupBlackViewFrame()
            
            containerView.addSubview(self.blackView)
            
            self.setupBackingView()
            if #available(iOS 11.0, *) {
                self.popupContentView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
            }
        }
 
        self.popupContentView.autoresizesSubviews = false
        self.popupContentView.contentView.autoresizesSubviews = false
        
        containerView.addSubview(self.popupContentView)
        self.popupContentView.updatePopupCloseButtonPosition()
        
        if self.popupPresentationStyle == .deck {
            coordinator.animate(alongsideTransition: { (context) in
                
                self.animateBackingViewToDeck(true, animated: true)
                
            }) { (context) in
                //
            }
        }
    }
    
    override func presentationTransitionDidEnd(_ completed: Bool) {
        if !completed {
            self._cleanup()
        }
        else {
            self.blackView.alpha = 1.0
        }
    }
    
    override func dismissalTransitionWillBegin() {
        guard self.presentedView != nil else { return }
        guard self.containerView != nil else { return }
        guard let coordinator = self.presentedViewController.transitionCoordinator else { return }

        //presentingVC.beginAppearanceTransition(true, animated: true)
        
        self.popupBarForPresentation = self.setupPopupBarForPresentation()
        
        if self.popupPresentationState == .closing || self.popupPresentationState == .open {
            if self.popupPresentationStyle == .deck {
                self.setupBackingView()
                self.animateBackingViewToDeck(true, animated: false)
                
                coordinator.animate(alongsideTransition: { (context) in
                    
                    self.animateBackingViewToDeck(false, animated: true)
                    
                }) { (context) in
                    //
                }
            }
        }
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        
        if completed {
            self._cleanup()
            //self.presentingVC.endAppearanceTransition()
        }
        else {
            self.blackView.alpha = 1.0
        }
    }
    
    private func _cleanup() {
        
        if self.popupPresentationStyle == .deck {
            self.blackView.removeFromSuperview()
            self.dimmerView.removeFromSuperview()
        }
        self.backingView?.removeFromSuperview()
        self.presentedView?.removeFromSuperview()
        self.popupContentView.removeFromSuperview()
    }
}

extension PBPopupPresentationController: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return self.popupContentView.popupPresentationDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard (transitionContext.viewController(forKey: self.isPresenting ? .to : .from)) != nil else { return }
        guard let presentedView = transitionContext.view(forKey: self.isPresenting ? .to : .from) else { return }
                
        if self.isPresenting {
            
            self.popupContentView.contentView.addSubview(presentedView)
            self.popupContentView.contentView.sendSubviewToBack(presentedView)

            self.popupContentView.frame = self.popupContentViewFrameForPopupStateClosed()
            presentedView.frame = self.presentedViewFrameForPopupStateClosed()
            
            self.popupContentView.popupCloseButton?.alpha = 0.0
            
            self.popupContentView.setupCornerRadiusTo(0.0, rect: self.popupContentViewFrameForPopupStateOpen())
            
            self.popupContentView.contentView.addSubview(self.popupBarForPresentation)
            
            self.imageViewForPresentation = self.setupImageViewForPresentation()
            if self.imageViewForPresentation != nil {
                self.popupContentView.contentView.addSubview(self.imageViewForPresentation!)
                self.configureImageModuleInStartPosition()
            }

            self.configureControlsModuleInStartPosition()
            
            self.popupContentView.layoutIfNeeded()
            
            let animations: (() -> Void) = {() -> Void in
                self.popupContentView.frame = self.popupContentViewFrameForPopupStateOpen()
                presentedView.frame = self.presentedViewFrameForPopupStateOpen()

                if self.popupPresentationStyle == .deck {
                    self.popupContentView.updateCornerRadiusTo(10.0, rect: self.popupContentViewFrameForPopupStateOpen())
                }
                
                self.animateImageModuleInFinalPosition()
                
                self.animateControlsModuleInFinalPosition()
                
                self.popupContentView.layoutIfNeeded()
            }
            
            let options: UIView.AnimationOptions = transitionContext.isInteractive ? [.curveLinear] : [.curveEaseInOut]
            
            let completion: (() -> Void) = {() -> Void in
                self.popupContentView.popupImageView?.isHidden = false
                self.popupContentView.popupImageModule?.isHidden = false
                self.popupBarForPresentation?.removeFromSuperview()
                self.popupBarForPresentation = nil
                self.imageViewForPresentation?.removeFromSuperview()
                self.imageViewForPresentation = nil
                if transitionContext.transitionWasCancelled {
                    self.popupContentView.popupCloseButton?.setButtonStateStationary()
                    
                    // Restore the initial frame after cancel presenting
                    self.configureControlsModuleInOriginalPosition()
               }
                else {
                    self.popupContentView.popupCloseButton?.alpha = 1.0
                }
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
            
            popupContentView.popupCloseButton?.alpha = 0.0
            popupContentView.popupCloseButton?.setButtonStateStationary()
            self.popupBarForPresentation?.alpha = 1.0

            if transitionContext.isInteractive {
                // Fix iOS 10 bug when cancel interactive presentation animation
                if ProcessInfo.processInfo.operatingSystemVersion.majorVersion == 10 {
                    if self.popupPresentationStyle == .deck {
                        UIView.animate(withDuration: self.popupContentView.popupPresentationDuration) {
                            self.popupContentView.updateCornerRadiusTo(10.0, rect: self.popupContentViewFrameForPopupStateOpen())
                        }
                    }
                    if #available(iOS 10.0, *) {
                        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: self.popupContentView.popupPresentationDuration, delay: 0.0, options: options, animations: {
                            animations()
                        }) { (_) in
                            completion()
                        }
                    }
                }
                else {
                    UIView.animate(withDuration: self.popupContentView.popupPresentationDuration, delay: 0.0, options: options, animations: {
                        animations()
                    }) { (finished) in
                        completion()
                    }
                }
            }
            else {
                UIView.animate(withDuration: self.popupContentView.popupPresentationDuration, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.5, options: options, animations: {
                    animations()
                    self.presentingVC._animateBottomBarToHidden(true)
                    self.popupBarForPresentation?.alpha = 0.0
                    self.popupContentView.popupCloseButton?.alpha = 1.0
                }, completion: { (finished) in
                    completion()
                })
            }
        }
        // Dismiss
        else {
            self.popupContentView.frame = self.popupContentViewFrameForPopupStateOpen()
            presentedView.frame = self.presentedViewFrameForPopupStateOpen()
            
            self.popupContentView.contentView.addSubview(self.popupBarForPresentation)
            
            self.imageViewForPresentation = self.setupImageViewForPresentation()
            
            if self.imageViewForPresentation != nil {
                self.popupContentView.contentView.addSubview(self.imageViewForPresentation!)
                self.configureImageModuleInStartPosition()
            }

            self.configureControlsModuleInStartPosition()

            self.popupBarView.alpha = 0.0
            
            self.popupContentView.layoutIfNeeded()
            
            let animations: (() -> Void) = {() -> Void in
                
                self.popupContentView.frame = self.popupContentViewFrameForPopupStateClosed()
                presentedView.frame = self.presentedViewFrameForPopupStateClosed()

                self.popupContentView.updateCornerRadiusTo(0.0, rect: self.popupContentViewFrameForPopupStateOpen())

                if !transitionContext.isInteractive {
                    self.animateImageModuleInFinalPosition()
                    self.animateControlsModuleInFinalPosition()
                }
                self.popupContentView.layoutIfNeeded()
            }
            
            let options: UIView.AnimationOptions = transitionContext.isInteractive ? [.curveLinear] : [.curveEaseInOut]
            
            let completion: (() -> Void) = {() -> Void in
                self.popupBarView.alpha = 1.0
                self.popupContentView.popupImageView?.isHidden = false
                self.popupContentView.popupImageModule?.isHidden = false
                self.popupBarForPresentation?.removeFromSuperview()
                self.popupBarForPresentation = nil
                self.imageViewForPresentation?.removeFromSuperview()
                self.imageViewForPresentation = nil

                self.popupContentView.popupCloseButton?.setButtonStateStationary()
                
                // Restore the initial frame after dismiss
                self.configureControlsModuleInOriginalPosition()

                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
            
            self.popupContentView.popupCloseButton?.setButtonStateTransitioning()
            self.popupBarForPresentation?.alpha = 0.0

            if transitionContext.isInteractive {
                // This is a workarround: In iOS 10, there is a bug when when the interactive interaction is cancelled.
                if ProcessInfo.processInfo.operatingSystemVersion.majorVersion == 10 {
                    UIView.animate(withDuration: self.popupContentView.popupPresentationDuration) {
                        self.popupContentView.updateCornerRadiusTo(0.0, rect: self.popupContentViewFrameForPopupStateOpen())
                    }
                    
                    if #available(iOS 10.0, *) {
                        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: self.popupContentView.popupPresentationDuration, delay: 0.0, options: options, animations: {
                            animations()
                        }) { (_) in
                            completion()
                        }
                    }
                }
                //
                else {
                    UIView.animate(withDuration: self.popupContentView.popupPresentationDuration, delay: 0.0, options: options, animations: {
                        animations()
                    }) { (finished) in
                        completion()
                    }
                }
            }
            else {
                UIView.animate(withDuration: self.popupContentView.popupPresentationDuration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: options, animations: {
                    animations()
                    self.presentingVC._animateBottomBarToHidden(false)
                    self.popupContentView.popupCloseButton?.alpha = 0.0
                    self.popupBarForPresentation?.alpha = 1.0
                }, completion: { (finished) in
                    completion()
                })
            }
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { (context) in
            if self.popupPresentationState == .open {
                if self.popupPresentationStyle == .deck {
                    self.blackView.frame = self.popupBlackViewFrame()
                }
                self.popupContentView.frame = self.popupContentViewFrameForPopupStateOpen()
                self.presentedView?.frame = self.presentedViewFrameForPopupStateOpen()
                self.popupContentView.updatePopupCloseButtonPosition()
                self.popupContentView.updateCornerRadiusTo(self.popupPresentationStyle == .deck ? 10.0 : 0.0, rect: self.popupContentViewFrameForPopupStateOpen())
            }
            self.popupBarView.frame.size.width = self.popupContentView.bounds.width
        }) { (context) in
            if self.popupPresentationState == .open {
                if self.popupPresentationStyle == .deck {
                    self.setupBackingView()
                    self.animateBackingViewToDeck(true, animated: false)
                }
                if let controlsModule = self.popupContentView.popupControlsModule {
                    self.controlsModuleFrameForPopupStateOpen = controlsModule.frame
                }
            }
        }
    }
}

// MARK: - Frames

extension PBPopupPresentationController {
    private func popupBlackViewFrame() -> CGRect {
        var frame = self.popupContentViewFrameForPopupStateOpen()
        frame.origin.y = 0
        frame.size.height = self.presentingVC.defaultFrameForBottomBar().origin.y - self.presentingVC.insetsForBottomBar().bottom
        PBLog("\(frame)")
        return frame
    }
    
    private func popupContentViewFrameForPopupStateClosed() -> CGRect {
        
        let frame = self.popupController.popupBarViewFrameForPopupStateClosed()
        PBLog("\(frame)")
        return frame
    }
    
    private func presentedViewFrameForPopupStateClosed() -> CGRect {
        var frame = self.popupContentViewFrameForPopupStateClosed()
        frame.origin.x = 0
        frame.origin.y = 0
        frame.size.height = self.popupContentViewFrameForPopupStateOpen().height
        PBLog("\(frame)")
        return frame
    }
    
    internal func popupContentViewFrameForPopupStateOpen() -> CGRect {

        var y: CGFloat = 0.0
        
        if self.popupPresentationStyle == .deck {
            y = self.statusBarFrame.height + self.popupContentViewTopInset
        }
        else if self.popupPresentationStyle == .custom {
            y = self.presentingVC.view.bounds.height - self.popupContentView.popupContentSize.height
        }
        if self.hackForSplitViewController {
            containerView?.frame = self.presentingViewFrameForPopupStateOpen_hackIfSplit()
        }
        else {
            containerView?.frame = self.presentingVC.view.frame
        }

        let frame = CGRect(x: 0.0, y: y, width: self.presentingVC.view.bounds.width, height: self.presentingVC.view.bounds.height - y)
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
    
    private func presentingViewFrameForPopupStateOpen_hackIfSplit() -> CGRect {
        var frame: CGRect = self.presentingVC.view.frame
        var x: CGFloat = self.presentingVC.view.frame.origin.x
        var y: CGFloat = self.presentingVC.view.frame.origin.y

        if let splitVC = self.presentingVC.splitViewController, self.presentingVC == splitVC.viewControllers.first {
            if self.presentingVC.view.frame.origin.x < 0.0 {
                self.containerView?.isHidden = false
                x = 0.0; y = 0.0
            }
            else {
                let orientation = UIApplication.shared.statusBarOrientation
                if orientation == .portrait || orientation == .portraitUpsideDown {
                    if splitVC.displayMode == .automatic || splitVC.displayMode == .primaryHidden {
                        self.containerView?.isHidden = true
                    }
                }
            }
        }
        
        frame.origin.x = x
        frame.origin.y = y

        PBLog("\(frame)")
        return frame
    }
    
    // MARK: - Snapshot views
    
    private func rectForPopupBarForPresentation() -> CGRect {
        let rect: CGRect = self.popupBarView.frame
        //rect.size.height = self.presentingVC.popupBar.popupBarHeight
        return rect
    }
    
    private func setupBackingView() {
        self.dimmerView.removeFromSuperview()
        self.backingView?.removeFromSuperview()
        
        let isHidden = self.popupBarView.isHidden
        self.popupBarView.isHidden = true
        let alpha = self.popupBarView.alpha
        self.popupBarView.alpha = 0.0
        
        let imageRect = self.blackView.bounds
        
        //for debug
        //let image = presentingVC.view.makeSnapshot(from: imageRect)
        
        self.backingView = self.presentingVC.view.resizableSnapshotView(from: imageRect, afterScreenUpdates: true, withCapInsets: .zero)
        self.backingView.autoresizingMask = []

        self.popupBarView.isHidden = isHidden
        self.popupBarView.alpha = alpha
        
        self.backingView.frame = imageRect
        self.backingView.frame.origin.x = 0

        self.backingView.clipsToBounds = true
        
        self.backingView.setupCornerRadiusTo(0.0, rect: self.backingView.frame)
        
        self.dimmerView.frame = self.backingView.bounds
        self.backingView.addSubview(self.dimmerView)
        
        self.blackView.addSubview(self.backingView)
    }

    private func animateBackingViewToDeck( _ deck: Bool, animated: Bool) {

        if deck == true {
            if !animated {
                self.backingView.setupCornerRadiusTo(10.0, rect: self.backingView.frame)
            }
            else {
                self.backingView.updateCornerRadiusTo(10.0, rect: self.backingView.frame)
            }
            self.dimmerView.alpha = 0.5
            self.backingView.transform = self.backingView.transform.scaledBy(x: 0.95, y: self.statusBarFrame.height > 0 ? 0.95 : 1.0)
            self.backingView.transform = self.backingView.transform.translatedBy(x: 0, y: self.statusBarFrame.height - (self.statusBarFrame.height > 0 ? (self.presentingVC.view.bounds.height * 0.05 / 2) : 0.0))
        }
        else {
            self.backingView.updateCornerRadiusTo(0.0, rect: self.backingView.bounds)
            self.dimmerView.alpha = 0.0
            self.backingView.transform = .identity
        }
    }
    
    private func setupPopupBarForPresentation() -> UIView? {
        
        let alpha = self.popupBarView.alpha
        self.popupBarView.alpha = 1.0
        
        if !self.isCompactOrPhoneInLandscape() {
            self.presentingVC.popupBar.imageView.isHidden = true
        }

        let rect = self.rectForPopupBarForPresentation()
        
        //for debug
        //let image = self.presentingVC.view.makeSnapshot(from: rect)
        
        let view = self.presentingVC.view.resizableSnapshotView(from: rect, afterScreenUpdates: true, withCapInsets: .zero)
        
        if self.presentingVC.popupBar.popupBarStyle == .prominent {
            self.presentingVC.popupBar.imageView.isHidden = false
        }
        
        self.popupBarView.alpha = alpha
        
        return view
    }
    
    private func setupImageViewForPresentation() -> PBPopupRoundShadowImageView? {
        
        if self.isCompactOrPhoneInLandscape() {return nil}
        
        if self.presentingVC.popupBar.popupBarStyle == .prominent, let imageModule = self.popupContentView.popupImageModule, let artImageView = self.popupContentView.popupImageView {
            
            let moduleView = PBPopupRoundShadowImageView(frame: imageModule.frame)
            
            moduleView.image = artImageView.image
            moduleView.imageView.contentMode = artImageView.contentMode
            moduleView.imageView.clipsToBounds = artImageView.clipsToBounds
            
            moduleView.clipsToBounds = imageModule.clipsToBounds
            moduleView.shadowColor = UIColor(cgColor: imageModule.layer.shadowColor ?? UIColor.black.cgColor)
            moduleView.shadowOffset = imageModule.layer.shadowOffset
            moduleView.shadowOpacity = CGFloat(imageModule.layer.shadowOpacity)
            moduleView.shadowRadius = imageModule.layer.shadowRadius
            
            return moduleView
        }
        return nil
    }
    
    // MARK: - Image module
    
    private func configureImageModuleInStartPosition() {
        
        if self.isCompactOrPhoneInLandscape() {return}

        if self.presentingVC.popupBar.popupBarStyle == .prominent, let imageViewForPresentation = self.imageViewForPresentation, let imageModule = self.popupContentView.popupImageModule, let imageView = self.popupContentView.popupImageView {
            if self.isPresenting {
                let closedFrame = self.presentingVC.popupBar.convert(self.presentingVC.popupBar.imageView.frame, to: self.popupContentView)
                imageViewForPresentation.frame = closedFrame
                imageViewForPresentation.cornerRadius = 3.0
            }
            else {
                    if var openFrame = presentedView?.convert(imageModule.frame, to: self.popupContentView) {
                        if #available(iOS 11.0, *) {
                            openFrame.origin.x += presentedView!.safeAreaInsets.left
                        }
                        imageViewForPresentation.frame = openFrame
                    }
                imageViewForPresentation.cornerRadius = imageView.layer.cornerRadius
                imageViewForPresentation.isHidden = false
            }
            imageModule.isHidden = true
        }
    }
    
    internal func animateImageModuleInFinalPosition() {
        
        if self.isCompactOrPhoneInLandscape() {return}
        
        if self.presentingVC.popupBar.popupBarStyle == .prominent, let imageViewForPresentation = self.imageViewForPresentation, let imageModule = self.popupContentView.popupImageModule, let imageView = self.popupContentView.popupImageView {
            if self.isPresenting {
                if var openFrame = presentedView?.convert(imageModule.frame, to: self.popupContentView) {
                    if #available(iOS 11.0, *) {
                        openFrame.origin.x += presentedView!.safeAreaInsets.left
                    }
                    imageViewForPresentation.frame = openFrame
                }
                imageViewForPresentation.cornerRadius = imageView.layer.cornerRadius
            }
            else {
                imageViewForPresentation.cornerRadius = 3.0
                let closedFrame = self.presentingVC.popupBar.convert(self.presentingVC.popupBar.imageView.frame, to: self.popupContentView)
                imageViewForPresentation.frame = closedFrame
            }
        }
    }
    
    // MARK: - Controls module
    
    private func configureControlsModuleInStartPosition() {
        if self.presentingVC.popupBar.popupBarStyle == .prominent, let imageViewForPresentation = self.imageViewForPresentation, let controlsModule = self.popupContentView.popupControlsModule, let controlsModuleTopConstraint = self.popupContentView.popupControlsModuleTopConstraint {
            
            
            if self.isPresenting {
                self.presentedView?.layoutIfNeeded()
                let openFrame = controlsModule.frame
                // Save the controls module real position when open
                self.controlsModuleFrameForPopupStateOpen = openFrame
                // Move up controls module just below imageForPresentation
                controlsModule.frame.origin.y = imageViewForPresentation.frame.origin.y + imageViewForPresentation.frame.height + controlsModuleTopConstraint.constant
            }
            else {
                if self.controlsModuleFrameForPopupStateOpen != .zero {
                    controlsModule.frame = self.controlsModuleFrameForPopupStateOpen
                }
            }
        }
    }

    internal func animateControlsModuleInFinalPosition() {
        if self.presentingVC.popupBar.popupBarStyle == .prominent, let imageViewForPresentation = self.imageViewForPresentation, let controlsModule = self.popupContentView.popupControlsModule, let controlsModuleTopConstraint = self.popupContentView.popupControlsModuleTopConstraint {
            
            if self.isPresenting {
                // Animate controls module frame to its open position
                controlsModule.frame = self.controlsModuleFrameForPopupStateOpen
            }
            else {
                controlsModule.frame.origin.y = imageViewForPresentation.frame.origin.y + imageViewForPresentation.frame.height + controlsModuleTopConstraint.constant
            }
        }
    }
    
    private func configureControlsModuleInOriginalPosition() {

        if self.presentingVC.popupBar.popupBarStyle == .prominent, let controlsModule = self.popupContentView.popupControlsModule {
            
            if self.controlsModuleFrameForPopupStateOpen != .zero {
                controlsModule.frame = self.controlsModuleFrameForPopupStateOpen
            }
        }
    }
    
    // MARK: - Helpers
    
    private func isCompactOrPhoneInLandscape() -> Bool {
        let orientation = UIApplication.shared.statusBarOrientation
        return UIDevice.current.userInterfaceIdiom == .phone && (orientation == .landscapeLeft || orientation == .landscapeRight)
    }
}
