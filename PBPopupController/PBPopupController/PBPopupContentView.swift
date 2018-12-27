//
//  PBPopupContentView.swift
//  PBPopupController
//
//  Created by Patrick BODET on 19/10/2018.
//  Copyright © 2018 Patrick BODET. All rights reserved.
//

import UIKit

@objc public class PBPopupContentView: UIView {
    
    // MARK: - Public Properties
    
    /**
     The visual effect view behind the popup content view (read-only, but its effect can be set to nil).
    */
    @objc public internal(set) var popupEffectView: UIVisualEffectView!
    
    /**
     The popup content view presentation style.
     
     Default presentation style: fullScreen for iOS 9 and above, otherwise deck.
     */
    @objc public var popupPresentationStyle = PBPopupPresentationStyle.default
    
    /**
     The popup content view presentation duration when presenting from closed to open state, or dismissing.
     */
    @objc public var popupPresentationDuration: TimeInterval = 0.6
    
    /**
     The popup content view size when popupPresentationStyle is set to custom.
     */
    @objc public var popupContentSize: CGSize {
        get {
            let size = CGSize(width: self.popupController.containerViewController.view.bounds.width * self.size.width, height: self.popupController.containerViewController.view.bounds.height * self.size.height)
            return size
        }
        set {
            self.size = CGSize(width: (newValue.width / self.popupController.containerViewController.view.bounds.width), height: (newValue.height / self.popupController.containerViewController.view.bounds.height))
        }
    }
    
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
    @objc public var popupControlsModule: UIView?
    
    /**
     Required if popupControlsModule is provided. This is the top constraint against the popupImageModule view.
     */
    @objc public var popupControlsModuleTopConstraint: NSLayoutConstraint?
    
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
    
    internal var popupCloseButton: PBPopupCloseButton!
    
    // The size of the popup content view (see popupContentSize).
    internal var size: CGSize! = .zero

    private var popupCloseButtonTopConstraint: NSLayoutConstraint!
    private var popupCloseButtonHorizontalConstraint: NSLayoutConstraint!
    
    internal var contentView: UIView {
        get {
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
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        PBLog("deinit \(self)")
    }
    
    // MARK: - private Methods
    
    private func setupEffectView() {
        let effect = UIBlurEffect(style: .light)
        self.popupEffectView = PBPopupEffectView(effect: effect)        
        
        self.addSubview(self.popupEffectView)

        self.popupEffectView.translatesAutoresizingMaskIntoConstraints = false
        self.popupEffectView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        self.popupEffectView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0).isActive = true
        self.popupEffectView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0).isActive = true
        self.popupEffectView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        
    }

    private func setupPopupCloseButton()
    {
        self.popupCloseButton?.removeFromSuperview()
        self.popupCloseButton = nil
        if self.popupCloseButtonStyle != .none {
            self.popupCloseButton = PBPopupCloseButton(style: popupCloseButtonStyle)
            self.popupCloseButton.alpha = 0.0
            self.popupCloseButton.addTarget(self.popupController, action: #selector(PBPopupController.closePopupContent), for: .touchUpInside)
            self.addSubview(self.popupCloseButton)
            self.popupCloseButton.translatesAutoresizingMaskIntoConstraints = false
            self.popupCloseButton?.setContentHuggingPriority(.required, for: .vertical)
            self.popupCloseButton?.setContentHuggingPriority(.required, for: .horizontal)
            self.popupCloseButton?.setContentCompressionResistancePriority(.required, for: .vertical)
            self.popupCloseButton?.setContentCompressionResistancePriority(.required, for: .horizontal)
            self.popupCloseButtonTopConstraint = self.popupCloseButton.topAnchor.constraint(equalTo: self.topAnchor, constant: self.popupCloseButtonStyle == .round ? /*12*/12 : 8)
            if self.popupCloseButtonStyle == .round {
                popupCloseButtonHorizontalConstraint = self.popupCloseButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 12)
            } else {
                self.popupCloseButtonHorizontalConstraint = self.popupCloseButton.centerXAnchor.constraint(equalTo: self.centerXAnchor)
            }
            NSLayoutConstraint.activate([popupCloseButtonTopConstraint, popupCloseButtonHorizontalConstraint])
        }
    }
    
    internal func updatePopupCloseButtonPosition()
    {
        if self.popupCloseButtonStyle != .none {
            
            let startingTopConstant: CGFloat = self.popupCloseButtonTopConstraint.constant
            self.popupCloseButtonTopConstraint.constant = self.popupCloseButtonStyle == .round ? /*12*/12 : 8
            var windowTopSafeAreaInset: CGFloat = 0
            if #available(iOS 11.0, *) {
                windowTopSafeAreaInset += (self.window?.safeAreaInsets.top)!
            }
            if self.popupPresentationStyle == .fullScreen {
                self.popupCloseButtonTopConstraint.constant += windowTopSafeAreaInset
            }
            
            if windowTopSafeAreaInset == 0 {
                if self.popupPresentationStyle == .fullScreen {
                    self.popupCloseButtonTopConstraint.constant += self.popupController.containerViewController.popupContentViewController.prefersStatusBarHidden == true ? 0 : UIApplication.shared.statusBarFrame.size.height
                }
            }

            let hitTest = self.popupController.containerViewController.popupContentViewController.view.hitTest(CGPoint(x: 12, y: popupCloseButtonTopConstraint.constant), with: nil)
            let possibleBar = _viewFor(hitTest, selfOrSuperviewKindOf: UINavigationBar.self) as? UINavigationBar
            if possibleBar != nil {
                if self.popupCloseButtonAutomaticallyUnobstructsTopBars {
                    self.popupCloseButtonTopConstraint.constant += possibleBar!.bounds.height
                }
                else {
                    self.popupCloseButtonTopConstraint.constant += 6.0
                }
            }
            
            if startingTopConstant != self.popupCloseButtonTopConstraint.constant {
                self.setNeedsUpdateConstraints()
                
                 UIView.animate(withDuration: UIApplication.shared.statusBarOrientationAnimationDuration, delay: 0.0, usingSpringWithDamping: 0.0, initialSpringVelocity: 0.0, options: [.allowUserInteraction, .allowAnimatedContent], animations: {
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
}

extension PBPopupContentView {
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
