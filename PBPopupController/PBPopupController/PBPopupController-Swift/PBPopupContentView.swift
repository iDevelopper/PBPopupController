//
//  PBPopupContentView.swift
//  PBPopupController
//
//  Created by Patrick BODET on 19/10/2018.
//  Copyright © 2018-2024 Patrick BODET. All rights reserved.
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
     The popup content view presentation duration when presenting from closed to open state.
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
     A Boolean value that indicates whether the popup is floating (`true`) or not (`false`).
     */
    @objc public var isFloating: Bool = false
    
    /**
     An optional inset for the floating content view.
     */
    @objc public var additionalFloatingBottomInset: CGFloat = 0.0

    /**
     If `true`, the popup content view can be dismissed when user interact outside the bounds.
     */
    @objc public var popupCanDismissOnPassthroughViews: Bool = true
    
    /**
     If `false` and `popupPresentationStyle` is  `PBPopupPresentationStyle.custom` or `PBPopupPresentationStyle.popup` , the popup container view has no dimmer view. Default value is `true`.
     
     - SeeAlso: `PBPopupPresentationStyle`.
     */
    @objc public var wantsPopupDimmerView: Bool = true
    
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
     
     - SeeAlso: `PBPopupCloseButtonStyle`.
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
    @objc public var popupCloseButtonAutomaticallyUnobstructsTopBars: Bool = true {
        didSet {
            self.setupPopupCloseButton()
        }
    }
    
    /**
     The view to which the popup interaction gesture recognizer should be added to. The default implementation returns the popup content view.
     
     - SeeAlso:
     `PBPopupController.popupContentPanGestureRecognizer`
     */
    @objc public var popupContentDraggingView: UIView!

    // MARK: - Private Properties
    
    internal weak var popupController: PBPopupController! {
        didSet {
            self.setupPopupCloseButton()
        }
    }
    
    // The size of the popup content view (see popupContentSize).
    internal var size: CGSize! = .zero
    
    private var popupCloseButtonTopConstraint: NSLayoutConstraint!
    private var popupCloseButtonVerticalConstraint: NSLayoutConstraint!
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
    
    /**
     :nodoc:
     */
    internal override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        self.setupEffectView()
        
        self.layer.cornerCurve = .continuous
    }
    
    required init(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        PBLog("deinit \(self)")
    }
    
    /**
     :nodoc:
     */
    public override func layoutSubviews()
    {
        super.layoutSubviews()
        
        if let popupEffectView = self.popupEffectView {
            popupEffectView.frame = self.bounds
        }
    }
    
    // MARK: - private Methods
    
    private func setupEffectView()
    {
        let effect = UIBlurEffect(style: .light)
        
        self.popupEffectView = PBPopupEffectView(effect: effect)
        self.popupEffectView.autoresizingMask = []
        self.popupEffectView.frame = self.bounds

        self.addSubview(self.popupEffectView)
    }
    
    private func setupPopupCloseButtonTintColor()
    {
        if self.popupCloseButtonStyle == .round {
            self.popupCloseButton.tintColor = UIColor.label
        }
        else {
            self.popupCloseButton.tintColor = UIColor.systemGray2
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
        guard let popupCloseButton = self.popupCloseButton else { return }
        
        if popupCloseButton.superview != self {
            let size = popupCloseButton.sizeThatFits(.zero)
            popupCloseButton.translatesAutoresizingMaskIntoConstraints = true
            popupCloseButton.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            return
        }
        
        if popupCloseButtonStyle != .none {
            self.popupCloseButtonTopConstraint.constant = self.popupCloseButtonStyle == .round ? 12 : 8
            let statusBarHeight = self.popupController.statusBarHeight(for: self.popupController.containerViewController.view)
            if self.popupPresentationStyle == .fullScreen || (self.popupPresentationStyle == .custom && self.popupContentSize.height == UIScreen.main.bounds.height) {
                self.popupCloseButtonTopConstraint.constant += self.popupController.containerViewController.popupContentViewController.prefersStatusBarHidden == true ? 0 : (self.popupController.isContainerPresentationSheet ? 0.0 : statusBarHeight)
            }
            if let navigationController = self.popupController.containerViewController.popupContentViewController as? UINavigationController {
                let possibleBar = navigationController.navigationBar
                if self.popupCloseButtonAutomaticallyUnobstructsTopBars {
                    self.popupCloseButtonVerticalConstraint = self.popupCloseButton.topAnchor.constraint(equalTo: possibleBar.bottomAnchor, constant: 8.0)
                }
                else {
                    self.popupCloseButtonVerticalConstraint = self.popupCloseButton.centerYAnchor.constraint(equalTo: possibleBar.centerYAnchor)
                }
                NSLayoutConstraint.deactivate([popupCloseButtonTopConstraint])
                NSLayoutConstraint.activate([popupCloseButtonVerticalConstraint])
            }
            
            if let vc = self.popupController.containerViewController.popupContentViewController {
                if self.popupCloseButtonStyle == .round {
                    self.popupCloseButtonHorizontalConstraint = popupCloseButton.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 12)
                } else {
                    self.popupCloseButtonHorizontalConstraint = popupCloseButton.centerXAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.centerXAnchor, constant: 0)
                }
                NSLayoutConstraint.activate([self.popupCloseButtonHorizontalConstraint])
            }
            
            self.setNeedsUpdateConstraints()
                
            UIView.performWithoutAnimation {
                self.layoutIfNeeded()
            }
        }
    }
    
    internal func superPopup() -> PBPopupContentView?
    {
        return self.popupContentViewFor(self)
    }
    
    internal func subPopup() -> PBPopupContentView?
    {
        return self.subviews(ofType: PBPopupContentView.self).first
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
    
    /**
     :nodoc:
     */
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView?
    {
        let view = super.hitTest(point, with: event)
        
        guard let popupCloseButton = self.popupCloseButton else { return view }
        let frame = popupCloseButton.convert(popupCloseButton.bounds, to: self)
        if frame.insetBy(dx: -20, dy: -20).contains(point) {
            return popupCloseButton
        }
        return view
    }
}

extension PBPopupContentView
{
    /**
     Custom views For Debug View Hierarchy Names
     */
    internal class PBPopupEffectView: UIVisualEffectView
    {
        internal override init(effect: UIVisualEffect?)
        {
            super.init(effect: effect)
        }
        
        required init(coder aDecoder: NSCoder)
        {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
