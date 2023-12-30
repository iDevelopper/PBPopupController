//
//  PBPopupInteractivePresentationController.swift
//  PBPopupController
//
//  Created by Patrick BODET on 01/07/2018.
//  Copyright © 2018-2023 Patrick BODET. All rights reserved.
//

import UIKit

protocol PBPopupInteractivePresentationDelegate : AnyObject
{
    func presentInteractive()
    func dismissInteractive()
}

internal class PBPopupInteractivePresentationController: UIPercentDrivenInteractiveTransition
{
    private var isPresenting: Bool!
    
    private var isDismissing: Bool!
    
    private weak var view: UIView!
        
    internal var contentOffset: CGPoint!
    
    private var gesture: UIPanGestureRecognizer!
        
    private var animator: UIViewPropertyAnimator!
    
    private var availableHeight: CGFloat = 0.0
    
    private var progress: CGFloat = 0.0
    
    private var location: CGFloat = 0.0
    
    private var shouldComplete = false
    
    private var statusBarThresholdDir = -1
    
    internal weak var delegate: PBPopupInteractivePresentationDelegate?
    
    private weak var popupController: PBPopupController!
    
    private var presentationController: PBPopupPresentationController!
    {
        return popupController.popupPresentationController
    }
    
    func attachToViewController(popupController: PBPopupController, withView view: UIView, presenting: Bool)
    {
        self.popupController = popupController
        self.view = view
        
        self.gesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(gesture:)))
        self.gesture.delegate = self
        if let popupBarTapGestureRecognizer = self.popupController.popupBarTapGestureRecognizer {
            popupBarTapGestureRecognizer.require(toFail: self.gesture)
        }
        view.addGestureRecognizer(self.gesture)
        if presenting {
            self.popupController.popupBarPanGestureRecognizer = self.gesture
        }
        else {
            self.popupController.popupContentPanGestureRecognizer = self.gesture
        }
        self.isPresenting = presenting
        self.isDismissing = false
    }
    
    deinit
    {
        PBLog("deinit \(self)")
    }
    
    override func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning)
    {
        super.startInteractiveTransition(transitionContext)
        self.animator = self.presentationController.interruptibleAnimator(using: transitionContext) as? UIViewPropertyAnimator
        if self.shouldComplete {
            if self.isPresenting {
                self.continuePresentationAnimation(0.6)
            }
            else {
                self.continueDismissalAnimation(0.6)
                self.isDismissing = false
            }
            self.finish()
            return
        }
        self.availableHeight = self.popupContainerViewAvailableHeight()
        self.progress = 0.0
        animator.fractionComplete = self.progress
        self.update(self.progress)
    }
    
    @objc private func handlePanGesture(gesture: UIPanGestureRecognizer)
    {
        guard let vc = self.popupController.containerViewController else { return }
        
        let translation = gesture.translation(in: gesture.view?.superview)
        
        if !self.isPresenting {
            if let scrollView = vc.popupContentViewController.view as? UIScrollView {
                if scrollView.contentOffset.y <= self.contentOffset.y {
                    if !self.isDismissing {
                        self.isDismissing = true
                        self.delegate?.dismissInteractive()
                        gesture.setTranslation(.zero, in: gesture.view?.superview)
                    }
                }
            }
        }
        
        switch gesture.state {
        case .began:
            self.animator = nil
            self.progress = 0.0
            self.location = 0.0
            self.shouldComplete = false
            
            if self.isPresenting {
                self.delegate?.presentInteractive()
            }
            else {
                if !self.isDismissing {
                    if !(vc.popupContentViewController.view is UIScrollView) {
                        self.isDismissing = true
                        self.delegate?.dismissInteractive()
                    }
                }
            }
            self.location = vc.popupContentView.frame.minY
            
            if self.isPresenting {
                self.location = self.popupController.popupBarView.frame.minY
            }
            
            if self.isDismissing {
                self.presentationController.imageViewForPresentation?.isHidden = true
                vc.popupContentView.popupImageView?.isHidden = false
                vc.popupContentView.popupImageModule?.isHidden = false
            }

            self.statusBarThresholdDir = self.isPresenting ? 1 : -1

        case .changed:
            if self.isDismissing, let scrollView = vc.popupContentViewController.view as? UIScrollView {
                scrollView.contentOffset = self.contentOffset
            }
            
            guard let animator = self.animator else { return }
            
            self.progress = translation.y / self.availableHeight

            if (self.progress >= 1 || self.progress <= 0) {
                self.progress = self.progress >= 1 ? 1 : 0
            }

            animator.fractionComplete = self.progress
            self.update(self.progress)
            
            if self.isPresenting {
                var alpha = (0.30 - self.progress) / 0.30
                alpha = alpha < 0 ? 0 : alpha > 1 ? 1 : alpha
                self.presentationController.popupBarForPresentation?.alpha = alpha
                alpha = (self.progress - 0.30) / 0.70
                alpha = alpha < 0 ? 0 : alpha > 1 ? 1 : alpha
                vc.popupContentView.popupCloseButton?.alpha = alpha
            }
            
            if ProcessInfo.processInfo.operatingSystemVersion.majorVersion < 17 {
                if let backingView = self.presentationController.backingView, let layerPresentation = backingView.layer.presentation() {
                    let statusBarFrame = self.popupController.statusBarFrame(for: vc.view)
                    let statusBarHeightThreshold = statusBarFrame.minY + statusBarFrame.height / 2
                    let backingViewY = layerPresentation.frame.minY
                    
                    if self.statusBarThresholdDir == 1 && backingViewY >= statusBarHeightThreshold || self.statusBarThresholdDir == -1 && backingViewY < statusBarHeightThreshold {
                        self.popupController.popupStatusBarStyle = self.statusBarThresholdDir == 1 ? self.popupController.popupPreferredStatusBarStyle : self.popupController.containerPreferredStatusBarStyle
                        //UIView.animate(withDuration: 0.25, delay: 0.0, usingSpringWithDamping: 500, initialSpringVelocity: 0, options: []) {
                        // Apple Documentation: If you call this method within an animation block, the changes are animated along with the rest of the animation block.
                        vc.setNeedsStatusBarAppearanceUpdate()
                        //}
                        self.statusBarThresholdDir = -self.statusBarThresholdDir
                    }
                }
            }
            
            let location = self.location + (availableHeight * self.progress)
            self.popupController.delegate?.popupController?(self.popupController, interactivePresentationFor: vc.popupContentViewController, state: self.isPresenting ? .closed : .open, progress: self.progress, location: location)

        case .ended, .cancelled:
            guard let animator = self.animator else {
                self.shouldComplete = true
                return
            }
            
            self.shouldComplete = self.completionPosition() == .end
            
            if self.shouldComplete {
                if self.isPresenting {
                    self.continuePresentationAnimation()
                }
                else {
                    self.continueDismissalAnimation()
                }
                self.finish()
            }
            else {
                animator.isReversed = true
                if self.isPresenting {
                    self.popupController.popupBarPanGestureRecognizer?.isEnabled = false
                    
                    self.popupController.popupStatusBarStyle = self.popupController.containerPreferredStatusBarStyle
                    animator.addAnimations {
                        vc.setNeedsStatusBarAppearanceUpdate()
                    }
                    
                    animator.addCompletion { (_) in
                        let previousState = self.popupController.popupPresentationState
                        self.popupController.popupPresentationState = .closed
                        self.popupController.delegate?.popupController?(self.popupController, stateChanged: self.popupController.popupPresentationState, previousState: previousState)
                        self.popupController.popupBarPanGestureRecognizer?.isEnabled = true
                    }
                    
                    self.presentationController.popupBarForPresentation?.alpha = 1.0
                    
                    animator.continueAnimation(withTimingParameters: animator.timingParameters, durationFactor: self.progress == 0 ? 0.0 : animator.fractionComplete)
                }
                else {
                    self.popupController.popupStatusBarStyle = self.popupController.popupPreferredStatusBarStyle
                    
                    if self.isDismissing {
                        animator.addAnimations {
                            vc.setNeedsStatusBarAppearanceUpdate()
                            vc.popupContentView.popupCloseButton?.setButtonStateStationary()
                        }
                        if let scrollView = vc.popupContentViewController.view as? UIScrollView {
                            animator.addCompletion { (_) in
                                scrollView.contentOffset = self.contentOffset
                            }
                        }
                        animator.addCompletion { (_) in
                            let previousState = self.popupController.popupPresentationState
                            self.popupController.popupPresentationState = .open
                            self.popupController.delegate?.popupController?(self.popupController, stateChanged: self.popupController.popupPresentationState, previousState: previousState)
                        }
                        
                        self.presentationController.imageViewForPresentation?.isHidden = true
                        vc.popupContentView.popupImageView?.isHidden = false
                        vc.popupContentView.popupImageModule?.isHidden = false

                        animator.continueAnimation(withTimingParameters: nil, durationFactor: self.progress == 0 ? 0.0 : 1.0)
                    }
                }
                self.cancel()
            }
            self.isDismissing = false
            break
            
        default:
            break
        }
    }
    
    private func continuePresentationAnimation(_ durationFactor: CGFloat = 0.0)
    {
        guard let vc = self.popupController.containerViewController else { return }
        
        self.popupController.popupStatusBarStyle = self.popupController.popupPreferredStatusBarStyle
        
        animator.addAnimations {
            vc.setNeedsStatusBarAppearanceUpdate()
            vc.popupContentView.popupCloseButton?.alpha = 1.0
            self.presentationController.popupBarForPresentation?.alpha = 0.0
        }
        
        if durationFactor == 0.0 {
            animator.continueAnimation(withTimingParameters: nil, durationFactor: 1.0)
        }
        else {
            let timingParameters = UICubicTimingParameters(animationCurve: .easeInOut)
            animator.continueAnimation(withTimingParameters: timingParameters, durationFactor: durationFactor)
        }
        
        let previousState = self.popupController.popupPresentationState
        self.popupController.popupPresentationState = .opening
        self.popupController.delegate?.popupController?(self.popupController, stateChanged: self.popupController.popupPresentationState, previousState: previousState)
        self.popupController.delegate?.popupController?(self.popupController, willOpen: vc.popupContentViewController)
    }
    
    private func continueDismissalAnimation(_ durationFactor: CGFloat = 1.0)
    {
        guard let vc = self.popupController.containerViewController else { return }

        self.popupController.popupStatusBarStyle = self.popupController.containerPreferredStatusBarStyle

        animator.addAnimations {
            vc.setNeedsStatusBarAppearanceUpdate()
        }

        self.presentationController.imageViewForPresentation?.isHidden = false
        vc.popupContentView.popupImageView?.isHidden = true
        vc.popupContentView.popupImageModule?.isHidden = true
        
        self.popupController.popupBarPanGestureRecognizer?.isEnabled = false
        
        self.presentationController.continueDismissalAnimationWithDurationFactor(durationFactor)

        let previousState = self.popupController.popupPresentationState
        self.popupController.popupPresentationState = .closing
        self.popupController.delegate?.popupController?(self.popupController, stateChanged: self.popupController.popupPresentationState, previousState: previousState)
        self.popupController.delegate?.popupController?(self.popupController, willClose: vc.popupContentViewController)
    }
    
    private func completionPosition() -> UIViewAnimatingPosition
    {
        guard let vc = self.popupController.containerViewController else { return .current}
        let velocity = self.gesture.velocity(in: gesture.view?.superview).vector
        let isFlick = (velocity.magnitude > vc.popupContentView.popupCompletionFlickMagnitude)
        let isFlickDown = isFlick && (velocity.dy > 0.0)
        let isFlickUp = isFlick && (velocity.dy < 0.0)
        
        if (self.isPresenting == true && isFlickUp) || (self.isDismissing && isFlickDown) {
            return .end
        } else if (self.isPresenting == true && isFlickDown) || (self.isDismissing && isFlickUp) {
            return .start
        } else if self.animator.fractionComplete > vc.popupContentView.popupCompletionThreshold {
            return .end
        } else {
            return .start
        }
    }
    
    private func popupContainerViewAvailableHeight() -> CGFloat
    {
        guard let vc = self.popupController.containerViewController else { return 0.0 }
        
        if vc.popupContentView.popupPresentationStyle == .popup {
            let closedFrame = self.presentationController.popupContentViewFrameForPopupStateHidden(finish: true)
            let availableHeight = closedFrame.minY - self.presentationController.popupContentViewFrameForPopupStateOpen().minY
            return availableHeight
        }
        else {
            let closedFrame = self.popupController.popupBarViewFrameForPopupStateClosed()
            let availableHeight = (self.isPresenting ? closedFrame.minY : closedFrame.maxY) - self.presentationController.popupContentViewFrameForPopupStateOpen().minY
            return self.isPresenting ? -availableHeight : availableHeight
        }
    }
}

extension PBPopupInteractivePresentationController: UIGestureRecognizerDelegate
{
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool
    {
        let state = self.popupController.popupPresentationState
        if state == .closed && gesture.direction == .down { return false }
        if state == .open && gesture.direction == .up { return false }
        if gesture.direction == .right || gesture.direction == .left { return false }
        
        if self.popupController.delegate?.popupControllerPanGestureShouldBegin?(self.popupController, state: self.popupController.popupPresentationState) == false
        {
            return false
        }
        
        let gesture = gestureRecognizer as! UIPanGestureRecognizer
        if self.isPresenting && gesture.direction != .up
        {
            return false
        }
        let vc = self.popupController.containerViewController
        if !self.isPresenting && !(vc?.popupContentViewController.view is UIScrollView) && gesture.direction != .down
        {
            return false
        }
        if let popupContentView = gestureRecognizer.view as? PBPopupContentView {
            if popupContentView.subPopup() != nil {
                return false
            }
        }
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool
    {
        if NSStringFromClass(type(of: otherGestureRecognizer.view!).self).contains("DropShadow") {
            otherGestureRecognizer.state = UIGestureRecognizer.State.failed
            return true
        }
        if otherGestureRecognizer == self.popupController.popupBarTapGestureRecognizer {
            otherGestureRecognizer.state = UIGestureRecognizer.State.failed
            return true
        }
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool
    {
        // Do not begin the pan until the tap fails.
        if gestureRecognizer == self.gesture && otherGestureRecognizer == self.popupController.popupBarTapGestureRecognizer {
            return true
        }
        return false
    }
}

private extension UIPanGestureRecognizer
{
    enum PanDirection: Int
    {
        case up, down, left, right
        var isVertical: Bool {
            return [.up, .down].contains(self)
        }
        var isHorizontal: Bool {
            return !isVertical
        }
    }
    
    var direction: PanDirection?
    {
        let velocity = self.velocity(in: view)
        let isVertical = abs(velocity.y) > abs(velocity.x)
        
        switch (isVertical, velocity.x, velocity.y) {
        case (true, _, let y) where y < 0:
            return .up
        case (true, _, let y) where y > 0:
            return .down
        case (false, let x, _) where x > 0:
            return .right
        case (false, let x, _) where x < 0:
            return .left
        default:
            return nil
        }
    }
}
