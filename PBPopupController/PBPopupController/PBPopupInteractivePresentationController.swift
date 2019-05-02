//
//  PBPopupInteractivePresentationController.swift
//  PBPopupController
//
//  Created by Patrick BODET on 01/07/2018.
//  Copyright © 2018 Patrick BODET. All rights reserved.
//

import UIKit

protocol PBPopupInteractivePresentationDelegate : class {
    func presentInteractive()
    func dismissInteractive()
}

internal class PBPopupInteractivePresentationController: UIPercentDrivenInteractiveTransition {
    
    private var isPresenting: Bool!
    
    // Set by own when scroll view is at the top (see contentOffset), also when view is not a scroll view.
    private var isDismissing: Bool!
    
    private var view: UIView!
    
    // Set by popupController when didOpen.
    internal var contentOffset: CGPoint!
    
    internal var gesture: UIPanGestureRecognizer!
    private weak var popupController: PBPopupController!
    
    private var progress: CGFloat = 0
    private var location: CGFloat = 0
    private var shouldComplete = false
    
    weak var delegate: PBPopupInteractivePresentationDelegate?
    
    private var presentationController: PBPopupPresentationController! {
        return popupController.popupPresentationController
    }
    
    func attachToViewController(popupController: PBPopupController, withView view: UIView, presenting: Bool) {
        self.popupController = popupController
        self.view = view
        
        self.gesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(gesture:)))
        self.gesture.delegate = self
        view.addGestureRecognizer(self.gesture)
        self.isPresenting = presenting
        self.isDismissing = false
        self.completionCurve = .linear
    }
    
    override var completionSpeed: CGFloat {
        get {
            return (self.shouldComplete ? 1.5 : 1.0) + self.percentComplete
        }
        set {}
    }

    @objc private func handlePanGesture(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: gesture.view?.superview)
        let availableHeight: CGFloat = self._popupContainerViewAvailableHeight()
        
        if !self.isPresenting {
            if self.view is UIScrollView && (self.view as! UIScrollView).contentOffset.y < self.contentOffset.y {
                if !self.isDismissing {
                    self.isDismissing = true
                    self.delegate?.dismissInteractive()
                    gesture.setTranslation(.zero, in: gesture.view?.superview)
                }
            }
        }
        
        if self.isPresenting || self.isDismissing {
            self.progress = translation.y / availableHeight
            self.location = gesture.location(in: gesture.view?.superview).y
        }

        switch gesture.state {
        case .began:
            self.progress = 0.0
            self.location = 0.0
            self.shouldComplete = false
            
            if self.isPresenting {
                self.delegate?.presentInteractive()
            }
            
            else {
                if !self.isDismissing {
                    if !(self.view is UIScrollView) {
                        self.isDismissing = true
                        self.delegate?.dismissInteractive()
                    }
                }
            }
            
        case .changed:
            if self.isDismissing && (self.view is UIScrollView) {
                let scrollView = self.view as! UIScrollView
                scrollView.contentOffset = self.contentOffset
            }
            
            let vc = self.popupController.containerViewController!
            
            self.shouldComplete = self.progress > 0.3
            
            if self.shouldComplete && !self.isPresenting {
                self.progress = 0.3 + (self.progress - 0.3) * 0.5
            }
            
            if self.isPresenting {
                let alpha = (0.30 - self.progress) / 0.30
                self.presentationController?.popupBarForPresentation?.alpha = alpha
                vc.popupContentView.popupCloseButton?.alpha = (self.progress - 0.30) / 0.70
            }
            
            if self.isPresenting && (self.progress >= 100 || self.progress <= 0) {
                    self.progress = self.progress >= 100 ? 100 : 0
            }
            
            let barHeight = self.popupController.bottomBarHeight + vc.insetsForBottomBar().bottom
            let barPosition = vc.view.frame.size.height - barHeight + (barHeight * (self.isPresenting ? progress : 1 - progress))
            vc._setBottomBarPosition(barPosition)
            
            if self.isPresenting || self.isDismissing {
                self.update(self.progress)
            }

            self.popupController.delegate?.popupController?(self.popupController, interactivePresentationFor: vc.popupContentViewController, state: popupController.popupPresentationState, progress: self.progress, location: self.location)
            
        case .cancelled:
            self.isDismissing = false
            self.cancel()
            
        case .ended:
            self.isDismissing = false

            if self.isPresenting {
                if (self.progress + (gesture.velocity(in: nil).y / availableHeight)) > 0.3 {
                    self.shouldComplete = true
                }
            }
            let vc = self.popupController.containerViewController!

            if self.shouldComplete {
                if self.isPresenting {
                    // finish()
                    UIView.animate(withDuration: TimeInterval(duration - (duration * percentComplete)), delay: 0.0, options: .curveLinear, animations: {
                        vc.popupContentView.popupCloseButton?.alpha = 1.0
                        self.presentationController?.animateImageModuleInFinalPosition()
                        self.presentationController?.animateControlsModuleInFinalPosition()
                        vc._animateBottomBarToHidden(true)
                    }) { (_) in
                        //
                    }
                
                    self.presentationController?.popupBarForPresentation?.alpha = 0.0
                    self.popupController.popupPresentationState = .opening
                    self.popupController.delegate?.popupController?(self.popupController, stateChanged: self.popupController.popupPresentationState, previousState: .closed)
                    self.popupController.delegate?.popupController?(self.popupController, willOpen: vc.popupContentViewController)
                }
                else {
                    self.presentationController?.containerView?.layoutIfNeeded()
                    UIView.animate(withDuration: TimeInterval((duration - (duration * percentComplete)) / completionSpeed), delay: 0.0, options: [.curveLinear], animations: {
                        vc.popupContentView.popupCloseButton?.alpha = 0.0
                        self.presentationController?.popupBarForPresentation?.alpha = 1.0
                        self.presentationController?.animateImageModuleInFinalPosition()
                        self.presentationController?.animateControlsModuleInFinalPosition()
                        vc._animateBottomBarToHidden(false)
                        
                        self.presentationController?.containerView?.layoutIfNeeded()
                    }) { (_) in
                        //
                    }
                    
                    self.popupController.popupPresentationState = .closing
                    self.popupController.delegate?.popupController?(self.popupController, stateChanged: self.popupController.popupPresentationState, previousState: .open)
                    self.popupController.delegate?.popupController?(self.popupController, willClose: vc.popupContentViewController)
                }
                self.finish()
            }
            else {
                //cancel()
                if self.isPresenting {
                    UIView.animate(withDuration: TimeInterval((duration * percentComplete) / completionSpeed), delay: 0.0, options: .curveLinear, animations: {
                        self.presentationController?.popupBarForPresentation?.alpha = 1.0
                        vc._animateBottomBarToHidden(false)
                    }) { (_) in
                        //
                    }
                    self.cancel()
                }
                else {
                    vc._animateBottomBarToHidden(true)
                    self.cancel()
                    if vc.popupContentView.popupPresentationStyle == .deck {
                        self.presentationController.backingView.setupCornerRadiusTo(10.0, rect: self.presentationController.backingView.bounds)
                        vc.popupContentView.updateCornerRadiusTo(10.0, rect: self.presentationController.popupContentViewFrameForPopupStateOpen())
                    }
                }
            }
            break
        default:
            break
        }
    }
    
    private func _popupContainerViewAvailableHeight() -> CGFloat {
        let vc = self.popupController.containerViewController!
        var availableHeight = vc.view.frame.size.height - vc.popupBar.frame.size.height - (vc.bottomBar.isHidden ? 0.0 : vc.bottomBar.frame.size.height)
        if vc.popupContentView.popupPresentationStyle == .custom {
            availableHeight = vc.popupContentView.popupContentSize.height - vc.popupBar.frame.size.height - (vc.bottomBar.isHidden ? 0.0 : vc.bottomBar.frame.size.height)
        }
        if #available(iOS 11.0, *) {
            availableHeight -= vc.insetsForBottomBar().bottom
        }
        return (self.popupController.popupPresentationState == .open ? availableHeight : -availableHeight)
    }
}

extension PBPopupInteractivePresentationController: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if self.popupController.delegate?.popupControllerPanGestureShouldBegin?(self.popupController, state: self.popupController.popupPresentationState) == false
        {
            return false
        }
        
        let gesture = gestureRecognizer as! UIPanGestureRecognizer
        if self.isPresenting && (gesture.direction == .down || gesture.direction == .left || gesture.direction == .right)
        {
            return false
        }
        if !self.isPresenting && !(self.view is UIScrollView) && (gesture.direction == .up || gesture.direction == .left || gesture.direction == .right)
        {
            return false
        }
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

internal extension UIPanGestureRecognizer {
    
    enum PanDirection: Int {
        case up, down, left, right
        var isVertical: Bool { return [.up, .down].contains(self) }
        var isHorizontal: Bool { return !isVertical }
    }
    
    var direction: PanDirection? {
        let velocity = self.velocity(in: view)
        let isVertical = abs(velocity.y) > abs(velocity.x)
        switch (isVertical, velocity.x, velocity.y) {
        case (true, _, let y) where y < 0: return .up
        case (true, _, let y) where y > 0: return .down
        case (false, let x, _) where x > 0: return .right
        case (false, let x, _) where x < 0: return .left
        default: return nil
        }
    }
}

private extension UIScrollView {
    
    var isAtTop: Bool {
        return contentOffset.y <= verticalOffsetForTop
    }
    
    var isAtBottom: Bool {
        return contentOffset.y >= verticalOffsetForBottom
    }
    
    var verticalOffsetForTop: CGFloat {
        let topInset = contentInset.top
        return -topInset
    }
    
    var verticalOffsetForBottom: CGFloat {
        let scrollViewHeight = bounds.height
        let scrollContentSizeHeight = contentSize.height
        let bottomInset = contentInset.bottom
        let scrollViewBottomOffset = scrollContentSizeHeight + bottomInset - scrollViewHeight
        return scrollViewBottomOffset
    }
}

private extension UIScrollView {
    
    var scrolledToTop: Bool {
        let topEdge = 0 - contentInset.top
        return contentOffset.y <= topEdge
    }
    
    var scrolledToBottom: Bool {
        let bottomEdge = contentSize.height + contentInset.bottom - bounds.height
        return contentOffset.y >= bottomEdge
    }
}
