//
//  PBPopupContentView.swift
//  PBPopupController
//
//  Created by Patrick BODET on 19/10/2018.
//  Copyright © 2018-2020 Patrick BODET. All rights reserved.
//

import UIKit

/**
 The view where is embedded the popupContentViewController's view for presentation. This view has a optional close button and a visual effect view with an optional effect.
 */
@objc public class PBPopupContentView: UIView {
    
    // MARK: - Public Properties
    
    /**
     The popup close button. (read-only).
     
     The popup content view controller can place the popup close button within its own view hierarchy, instead of the system-defined placement.
     */
    @objc public internal(set) var popupCloseButton: PBPopupCloseButton!
    
    /**
     The visual effect view behind the popup content view (read-only, but its effect can be set to nil).
     */
    @objc public internal(set) var popupEffectView: UIVisualEffectView!
    
    /**
     The popup content view presentation style.
     
     Default presentation style: deck, was fullScreen for iOS 9 and above, otherwise deck.
     */
    @objc public var popupPresentationStyle = PBPopupPresentationStyle.default
    
    /**
     The popup content view presentation duration when presenting from closed to open state, or dismissing.
     */
    @objc public var popupPresentationDuration: TimeInterval = 0.5
    
    /**
     The popup content view dismissal duration when dismissing from open to closed state.
     */
    @objc public var popupDismissalDuration: TimeInterval = 0.6
    
    /**
     The threshold value used to open or close the popup content view when dragging.
     */
    @objc public var popupCompletionThreshold: CGFloat = 0.3
    
    /**
     The flick magnitude value used to open or close the popup content view when dragging.
     */
    @objc public var popupCompletionFlickMagnitude: CGFloat = 1200
    
    /**
     The popup content view size when popupPresentationStyle is set to custom.
     */
    @objc public var popupContentSize: CGSize {
        get {
            let size = CGSize(width: UIScreen.main.bounds.width * self.size.width, height: UIScreen.main.bounds.height * self.size.height)
            return size
        }
        set {
            self.size = CGSize(width: (newValue.width / UIScreen.main.bounds.width), height: (newValue.height / UIScreen.main.bounds.height))
        }
    }
    
    /**
     If `true`, the popup content view can be dismissed when user interact outside the bounds.
     */
    @objc public var popupCanDismissOnPassthroughViews: Bool = true
    
    /**
     If `true`, tells the popup content view presentation to ignore the form sheet presentation by default.
     */
    @objc public var popupIgnoreDropShadowView: Bool = true
    
    /**
     The view containing the top subviews (i.e. labels, image view, etc...) of the popup content view controller (optional but needed if bottom module is used). Used to animate the popup presentation. This view will be used for correctly positioning the bottom module during presentation animation.
     */
    @objc public var popupTopModule: UIView?
    
    /**
     The image view's container view of the popup content view controller (optional). Useful for shadows. Used to animate the popup presentation.
     */
    @objc public var popupImageModule: UIView?
    
    /**
     The image view of the popup content view controller (optional). Used to animate the popup presentation.
     */
    @objc public var popupImageView: UIImageView?
    
    /**
     The view containing the controls subviews (i.e. playback buttons, volume slider, progress view, etc...) of the popup content view controller (optional). Used to animate the popup presentation. This view will be animated so as to be positioned under the image that grows.
     */
    @available(*, deprecated, message: "Use popupBottomModule and popupTopModule instead")
    @objc public var popupControlsModule: UIView?
    
    /**
     The view containing the controls subviews (i.e. playback buttons, volume slider, progress view, etc...) of the popup content view controller (optional). Used to animate the popup presentation. This view will be animated so as to be positioned under the image that grows.
     */
    @objc public var popupBottomModule: UIView?
    
    /**
     Required if popupControlsModule is provided. This is the top constraint against the popupImageModule view.
     */
    @available(*, deprecated, message: "Use popupBottomModuleTopConstraint instead")
    @objc public var popupControlsModuleTopConstraint: NSLayoutConstraint?
    
    /**
     Required if popupBottomModule is provided. This is the top constraint against the popupTopModule view.
     */
    @objc public var popupBottomModuleTopConstraint: NSLayoutConstraint?
    
    /**
     The popup close button style.
     
     - SeeAldo: `PBPopupCloseButtonStyle`.
     */
    @objc public var popupCloseButtonStyle: PBPopupCloseButtonStyle = .default {
        didSet {
            if oldValue != popupCloseButtonStyle {
                self.setupPopupCloseButton()
            }
        }
    }
    
    /**
     If `true`, move close button under navigation bars
     */
    @objc public var popupCloseButtonAutomaticallyUnobstructsTopBars: Bool = true
    
    // MARK: - Private Properties
    
    internal weak var popupController: PBPopupController! {
        didSet {
            self.setupPopupCloseButton()
        }
    }
    
    // The size of the popup content view (see popupContentSize).
    internal var size: CGSize! = .zero
    
    private var popupCloseButtonTopConstraint: NSLayoutConstraint!
    private var popupCloseButtonHorizontalConstraint: NSLayoutConstraint!
    
    internal var contentView: UIView {
        get {
            if self.popupEffectView == nil {
                return self
            }
            if self.popupEffectView.superview == nil {
                return self
            }
            if popupEffectView.effect == nil {
                self.popupEffectView.removeFromSuperview()
                return self
            }
            return self.popupEffectView.contentView
        }
    }
    
    // MARK: - Init
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupEffectView()
        if #available(iOS 13.0, *) {
            self.layer.cornerCurve = .continuous
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        PBLog("deinit \(self)")
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        if let popupEffectView = self.popupEffectView {
            popupEffectView.frame = self.bounds
        }
    }
    
    // MARK: - private Methods
    
    private func setupEffectView() {
        let effect = UIBlurEffect(style: .light)
        
        self.popupEffectView = PBPopupEffectView(effect: effect)
        self.popupEffectView.frame = self.bounds
        self.popupEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        self.addSubview(self.popupEffectView)
    }
    
    private func setupPopupCloseButtonTintColor() {
        if self.popupCloseButtonStyle == .round {
            if #available(iOS 13, *) {
                self.popupCloseButton.tintColor = UIColor.label
            }
            else {
                self.popupCloseButton.tintColor = UIColor.lightGray
            }
        }
        else {
            if #available(iOS 13, *) {
                self.popupCloseButton.tintColor = UIColor.systemGray2
            }
            else {
                self.popupCloseButton.tintColor = UIColor.lightGray
            }
        }
    }
    
    private func setupPopupCloseButton()
    {
        self.popupCloseButton?.removeFromSuperview()
        self.popupCloseButton = nil
        if self.popupCloseButtonStyle != .none {
            self.popupCloseButton = PBPopupCloseButton(style: popupCloseButtonStyle)
            self.setupPopupCloseButtonTintColor()
            self.popupCloseButton.addTarget(self.popupController, action: #selector(PBPopupController.closePopupContent), for: .touchUpInside)
            self.addSubview(self.popupCloseButton)
            self.popupCloseButton.translatesAutoresizingMaskIntoConstraints = false
            
            self.popupCloseButton.setContentHuggingPriority(.required, for: .vertical)
            self.popupCloseButton.setContentHuggingPriority(.required, for: .horizontal)
            self.popupCloseButton.setContentCompressionResistancePriority(.required, for: .vertical)
            self.popupCloseButton.setContentCompressionResistancePriority(.required, for: .horizontal)
            
            self.popupCloseButtonTopConstraint = self.popupCloseButton.topAnchor.constraint(equalTo: self.topAnchor, constant: self.popupCloseButtonStyle == .round ? 12 : 8)
            NSLayoutConstraint.activate([popupCloseButtonTopConstraint])
        }
    }
    
    internal func updatePopupCloseButtonPosition()
    {
        if self.popupCloseButton.superview != self {
            let size = self.popupCloseButton.sizeThatFits(.zero)
            self.popupCloseButton.translatesAutoresizingMaskIntoConstraints = true
            self.popupCloseButton.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            return
        }
        
        if self.popupCloseButtonStyle != .none {
            let startingTopConstant: CGFloat = self.popupCloseButtonTopConstraint.constant
            self.popupCloseButtonTopConstraint.constant = self.popupCloseButtonStyle == .round ? 12 : 8
            let statusBarHeight = self.popupController.statusBarHeight(for: self.popupController.containerViewController.view)
            let dropShadowView =  self.popupController.dropShadowViewFor(self.popupController.containerViewController.view)
            if self.popupPresentationStyle == .fullScreen {
                self.popupCloseButtonTopConstraint.constant += self.popupController.containerViewController.popupContentViewController.prefersStatusBarHidden == true ? 0 : (dropShadowView == nil ? statusBarHeight : 0.0)
            }
            
            let hitTest = self.popupController.containerViewController.popupContentViewController.view.hitTest(CGPoint(x: 12, y: popupCloseButtonTopConstraint.constant), with: nil)
            let possibleBar = _viewFor(hitTest, selfOrSuperviewKindOf: UINavigationBar.self) as? UINavigationBar
            if possibleBar != nil {
                if self.popupCloseButtonAutomaticallyUnobstructsTopBars {
                    self.popupCloseButtonTopConstraint.constant += possibleBar!.bounds.height
                }
                else {
                    self.popupCloseButtonTopConstraint.constant = possibleBar!.center.y - self.popupCloseButton.frame.height / 2
                }
            }
            
            if let vc = self.popupController.containerViewController.popupContentViewController {
                if self.popupCloseButtonStyle == .round {
                    self.popupCloseButtonHorizontalConstraint = self.popupCloseButton.leadingAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.leadingAnchor, constant: 12)
                } else {
                    if #available(iOS 13, *) {
                        self.popupCloseButtonHorizontalConstraint = self.popupCloseButton.centerXAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.centerXAnchor, constant: 0)
                    }
                    else {
                        self.popupCloseButtonHorizontalConstraint = self.popupCloseButton.centerXAnchor.constraint(equalTo: self.safeAreaLayoutGuide.centerXAnchor, constant: self.safeAreaInsets.left)
                    }
                }
                NSLayoutConstraint.activate([popupCloseButtonHorizontalConstraint])
            }
            
            if startingTopConstant != self.popupCloseButtonTopConstraint.constant {
                self.setNeedsUpdateConstraints()
                
                UIView.animate(withDuration: 0.25, delay: 0.0, usingSpringWithDamping: 500, initialSpringVelocity: 0.0, options: [.allowUserInteraction, .allowAnimatedContent], animations: {
                    self.layoutIfNeeded()
                }, completion: nil)
            }
        }
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
    
    /**
     :nodoc:
     */
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        let frame = self.popupCloseButton.convert(self.popupCloseButton.bounds, to: self)
        if frame.insetBy(dx: -20, dy: -20).contains(point) {
            return self.popupCloseButton
        }
        return view
    }
}

extension PBPopupContentView
{
    /**
     Custom views For Debug View Hierarchy Names
     */
    internal class PBPopupEffectView: UIVisualEffectView {
        internal override init(effect: UIVisualEffect?) {
            super.init(effect: effect)
        }
        
        required init(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
