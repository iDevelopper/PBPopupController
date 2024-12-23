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
     Gives the popup content controller the opportunity to place the popup close button within its own view hierarchy, instead of the system-defined placement.
     
     The popup content view controller can place the popup close button within its own view hierarchy, instead of the system-defined placement.
     */
    @objc public var popupCloseButtonIsUserPositioned: Bool = false
    
    /**
     The visual effect view behind the popup content view (read-only, but its effect can be set to nil).
     */
    @objc public internal(set) var popupEffectView: UIVisualEffectView!
    
    @objc internal var popupFloatingEffectView: UIVisualEffectView!
    
    /**
     If `true`, the popup content will automatically inherit its style from the popup bar.
     */
    @objc public var inheritsVisualStyleFromPopupBar: Bool = true {
        didSet {
            self.popupController.containerViewController.configurePopupContentViewFromPopupBar()
        }
    }
    
    /**
     The popup content view presentation style.
     
     Default presentation style: deck, was fullScreen for iOS 9 and above, otherwise deck.
     */
    @objc public var popupPresentationStyle = PBPopupPresentationStyle.default {
        didSet {
            if oldValue != popupPresentationStyle {
                self.setupPopupCloseButtonStyle(popupCloseButtonStyle)
            }
        }
    }
    
    /**
     The popup content view presentation duration when presenting from closed to open state.
     */
    @objc public var popupPresentationDuration: TimeInterval = 0.4
    
    /**
     The popup content view dismissal duration when dismissing from open to closed state.
     */
    @objc public var popupDismissalDuration: TimeInterval = 0.5
    
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
    @objc public var popupTopModule: UIView? {
        didSet {
            self.popupTopModuleBackgroundColor = self.popupTopModule?.backgroundColor
        }
    }
    
    /**
     The image view's container view of the popup content view controller (optional). Useful for shadows. Used to animate the popup presentation.
     */
    @objc public var popupImageModule: UIView? {
        didSet {
            self.popupImageModuleBackgroundColor = self.popupImageModule?.backgroundColor
        }
    }
    
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
    @objc public var popupBottomModule: UIView? {
        didSet {
            self.popupBottomModuleBackgroundColor = self.popupBottomModule?.backgroundColor
        }
    }
    
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
                self.popupCloseButton.style = popupCloseButtonStyle
            }
            self.setupPopupCloseButtonStyle(popupCloseButtonStyle)
        }
    }
    
    /**
     If `true`, move close button under navigation bars
     */
    @objc public var popupCloseButtonAutomaticallyUnobstructsTopBars: Bool = true {
        didSet {
            self.setupPopupCloseButtonStyle(popupCloseButtonStyle)
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
    
    internal weak var popupContentViewController: UIViewController! {
        didSet {
            self.setupPopupCloseButtonStyle(popupCloseButtonStyle)
        }
    }
    
    // The size of the popup content view (see popupContentSize).
    internal var size: CGSize! = .zero
    
    private var popupCloseButtonTopConstraint: NSLayoutConstraint!
    private var popupCloseButtonNavConstraint: NSLayoutConstraint!
    private var popupCloseButtonLeadingConstraint: NSLayoutConstraint!
    private var popupCloseButtonCenterConstraint: NSLayoutConstraint!
    
    internal var contentView: UIView {
        get {
            if let popupFloatingEffectView = self.popupFloatingEffectView {
                return popupFloatingEffectView.contentView
            }
            if let popupEffectView = self.popupEffectView {
                    return popupEffectView.contentView
            }
            if self.popupEffectView == nil {
                return self
            }
            return self
        }
    }
    
    internal var popupTopModuleBackgroundColor: UIColor?
    internal var popupImageModuleBackgroundColor: UIColor?
    internal var popupBottomModuleBackgroundColor: UIColor?

    // MARK: - Init
    
    /**
     :nodoc:
     */
    internal override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        self.preservesSuperviewLayoutMargins = true
        
        self.setupEffectView()
        
        self.setupFloatingEffectView()
        
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
        if let popupFloatingEffectView = self.popupFloatingEffectView {
            popupFloatingEffectView.frame = self.bounds
        }
    }
    
    // MARK: - public Methods
    
    /**
     Call this method to update the popup content view appearance (style, tint color, etc.) according to its docking view. You should call this after updating the docking view.
     If the popup content view's `inheritsVisualStyleFromPopupBar` property is set to `false`, this method has no effect.
     
     - SeeAlso: `PBPopupContentView.inheritsVisualStyleFromPopupBar`.
     */
    @objc public func updatePopupContentViewAppearance() {
        self.popupController.containerViewController.configurePopupContentViewFromPopupBar()
    }
    
    // MARK: - private Methods
    
    private func setupEffectView()
    {
        let effect = UIBlurEffect(style: .systemMaterial)

        self.popupEffectView = _PBPopupEffectView(effect: effect)
        self.popupEffectView.autoresizingMask = []
        self.popupEffectView.frame = self.bounds
        
        self.popupEffectView.preservesSuperviewLayoutMargins = true

        self.addSubview(self.popupEffectView)
    }
    
    private func setupFloatingEffectView()
    {
        self.popupFloatingEffectView = _PBPopupEffectView(effect: nil)
        self.popupFloatingEffectView.autoresizingMask = []
        self.popupFloatingEffectView.frame = self.bounds
        
        self.popupFloatingEffectView.preservesSuperviewLayoutMargins = true

        self.addSubview(self.popupFloatingEffectView)
    }
    
    private func setupPopupCloseButton()
    {
        self.popupCloseButton = PBPopupCloseButton(style: popupCloseButtonStyle)
        self.popupCloseButton.addTarget(self.popupController, action: #selector(PBPopupController.closePopupContent), for: .touchUpInside)
        
        self.popupCloseButton.setContentHuggingPriority(.required, for: .vertical)
        self.popupCloseButton.setContentHuggingPriority(.required, for: .horizontal)
        self.popupCloseButton.setContentCompressionResistancePriority(.required, for: .vertical)
        self.popupCloseButton.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
        
    private func setupPopupCloseButtonStyle(_ popupCloseButtonStyle: PBPopupCloseButtonStyle)
    {
        UIView.performWithoutAnimation
        {
            if self.popupCloseButtonIsUserPositioned {
                return
            }
            else {
                if self.popupCloseButton.superview != self.contentView {
                    self.contentView.addSubview(self.popupCloseButton)
                }
            }
            if popupCloseButtonStyle != .none {
                self.popupCloseButton?.isHidden = false
                
                self.popupCloseButton.translatesAutoresizingMaskIntoConstraints = false

                if self.popupCloseButtonTopConstraint == nil {
                    self.popupCloseButtonTopConstraint = self.popupCloseButton.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: self.popupCloseButtonStyle == .round ? 12 : 8)
                }
                else {
                    self.popupCloseButtonTopConstraint.constant = self.popupCloseButtonStyle == .round ? 12 : 8
                }
                
                if let navigationController = self.popupContentViewController as? UINavigationController {
                    let possibleBar = navigationController.navigationBar
                    if self.popupCloseButtonAutomaticallyUnobstructsTopBars {
                        self.popupCloseButtonNavConstraint = self.popupCloseButton.topAnchor.constraint(equalTo: possibleBar.bottomAnchor, constant: 8.0)
                    }
                    else {
                        self.popupCloseButtonNavConstraint = self.popupCloseButton.centerYAnchor.constraint(equalTo: possibleBar.centerYAnchor)
                    }
                }
                
                NSLayoutConstraint.activate([self.popupCloseButtonTopConstraint])
                
                if self.popupCloseButtonLeadingConstraint == nil {
                    self.popupCloseButtonLeadingConstraint = self.popupCloseButton.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 12)
                }
                
                if self.popupCloseButtonCenterConstraint == nil {
                    self.popupCloseButtonCenterConstraint = self.popupCloseButton.centerXAnchor.constraint(equalTo: self.contentView.safeAreaLayoutGuide.centerXAnchor)
                }
                
                if self.popupCloseButtonStyle == .round {
                    self.popupCloseButtonLeadingConstraint?.isActive = true
                    self.popupCloseButtonCenterConstraint?.isActive = false
                }
                else {
                    self.popupCloseButtonLeadingConstraint.isActive = false
                    self.popupCloseButtonCenterConstraint.isActive = true
                }
            }
            else {
                self.popupCloseButton?.isHidden = true
            }
        }
    }

    internal func updatePopupCloseButtonPosition(animated: Bool = false)
    {
        guard let popupCloseButton = self.popupCloseButton else { return }
        
        guard self.popupCloseButtonStyle != .none else { return }

        if popupCloseButton.superview != self.contentView {
            let size = popupCloseButton.sizeThatFits(.zero)
            if popupCloseButton.translatesAutoresizingMaskIntoConstraints == true {
                popupCloseButton.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            }
            return
        }
        
        guard let currentPopupContentViewController = self.popupController.containerViewController.popupContentViewController else { return }
        
        let layoutFrame = self.convert(currentPopupContentViewController.view.layoutMarginsGuide.layoutFrame, from: currentPopupContentViewController.view)

        var topConstant: CGFloat = 0.0
        
        if let navigationController = currentPopupContentViewController as? UINavigationController {
            let possibleBar = navigationController.navigationBar
            self.popupCloseButtonNavConstraint = self.popupCloseButton.centerYAnchor.constraint(equalTo: possibleBar.centerYAnchor)
            self.popupCloseButtonTopConstraint.isActive = false
            self.popupCloseButtonNavConstraint.isActive = true
        }
        else if self.popupPresentationStyle == .deck {
            topConstant = self.popupCloseButtonTopConstraint.constant
        }
        else if self.popupPresentationStyle == .popup {
            topConstant = self.popupCloseButtonTopConstraint.constant
        }
        else if (self.popupPresentationStyle == .custom && self.popupContentSize.height == UIScreen.main.bounds.height) {
            topConstant += layoutFrame.origin.y
            topConstant = max(popupCloseButton.style == .round ? 12: 8.0, topConstant)
        }
        else if self.popupPresentationStyle == .custom {
            topConstant = self.popupCloseButtonTopConstraint.constant
        }
        else if self.popupPresentationStyle == .fullScreen {
            topConstant += layoutFrame.origin.y
            topConstant = max(popupCloseButton.style == .round ? 12: 8.0, topConstant)
        }

        let leadingConstant = layoutFrame.origin.x
        
        if topConstant != self.popupCloseButtonTopConstraint.constant || leadingConstant != self.popupCloseButtonLeadingConstraint.constant {
            self.popupCloseButtonTopConstraint.constant = topConstant
            self.popupCloseButtonLeadingConstraint.constant = leadingConstant
            
            if animated == false {
                UIView.performWithoutAnimation {
                    self.layoutIfNeeded()
                }
            }
            else {
                UIView.animate(withDuration: 0.25, delay: 0.0, usingSpringWithDamping: 500, initialSpringVelocity: 0.0, options: [.allowUserInteraction, .allowAnimatedContent]) {
                    self.layoutIfNeeded()
                }
            }
        }
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
    internal class _PBPopupEffectView: UIVisualEffectView
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
