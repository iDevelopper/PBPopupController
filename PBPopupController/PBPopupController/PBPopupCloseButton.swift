//
//  PBPopupCloseButton.swift
//  PBPopupController
//
//  Created by Patrick BODET on 26/04/2018.
//  Copyright © 2018-2020 Patrick BODET. All rights reserved.
//

import UIKit

/**
 Available styles for the popup close button.
 
 Use the most appropriate close button style for the current operating system version. Uses chevron button style for iOS 10 and above, otherwise round button.
 */
@objc public enum PBPopupCloseButtonStyle : Int {
    
    /**
     Chevron close button style.
     */
    case chevron
    
    /**
     Round close button style.
     */
    case round
    
    /**
     No close button.
     */
    case none = 2
    
    /**
     Default style: Chevron button style for iOS 10 and above, otherwise round button.
     */
    public static let `default`: PBPopupCloseButtonStyle = {
        return .chevron
    }()
}

extension PBPopupCloseButtonStyle
{
    /**
     An array of human readable strings for the close button styles.
     */
    public static let strings = ["chevron", "round", "none"]
    
    private func string() -> NSString {
        return PBPopupCloseButtonStyle.strings[self.rawValue] as NSString
    }
    
    /**
     Return an human readable description for the popup close button style.
     */
    public var description: NSString {
        get {
            return string()
        }
    }
}

/**
 A button added to the content's view when the popup content view controller is presented. The user can dismiss the popup content view controller by either swiping or tapping this popup close button.
 */
@objc public class PBPopupCloseButton: UIButton {
    
    // MARK: - Public Properties
    
    /**
     The current style of the popup close button. (read-only)
     
     - Note: In order to change the button's style, set the `popupCloseButtonStyle` property of the popup content view.
     */
    @objc public private(set) var style: PBPopupCloseButtonStyle = .default
    
    /**
     The button’s background view. (read-only)
     
     The value of this property will be `nil` if `style` is not set to `PBPopupCloseButtonStyleRound`.
     
     - Note: Although this property is read-only, its own properties are read/write. Use these properties to configure the appearance and behavior of the button’s background view.
     */
    @objc public private(set) var backgroundView: UIVisualEffectView?
    
    // MARK: - Private Properties
    
    private var effectView: UIVisualEffectView!
    private var highlightView: UIView!
    private var chevronView: PBChevronView!
    
    /**
     The natural size for the receiving view, considering only properties of the view itself.
     */
    override public var intrinsicContentSize: CGSize {
        get {
            return self.sizeThatFits(.zero)
        }
    }
    
    // MARK: - Public Init
    
    public convenience init(style: PBPopupCloseButtonStyle) {
        self.init(customStyle: style)
    }
    
    /**
     :nodoc:
     */
    required public init(customStyle: PBPopupCloseButtonStyle) {
        self.style = customStyle
        
        super.init(frame: .zero)
        
        self.commonSetup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.commonSetup()
    }
    
    private func commonSetup() {
        if self.style == .round {
            self.setupForRoundButton()
        } else {
            self.setupForChevronButton()
        }
        accessibilityLabel = NSLocalizedString("Close", comment: "")
        accessibilityHint = NSLocalizedString("Double tap to close popup content", comment: "")
    }
    
    private func setupForRoundButton() {
        var blurStyle: UIBlurEffect.Style;
        if #available(iOS 13, *) {
            blurStyle = .systemChromeMaterial
        }
        else {
            blurStyle = .extraLight
        }
        self.effectView = UIVisualEffectView(effect: UIBlurEffect(style: blurStyle))
        self.effectView.isUserInteractionEnabled = false
        self.addSubview(self.effectView)
        
        let highlightEffectView = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: self.effectView.effect as! UIBlurEffect))
        highlightEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        highlightEffectView.frame = self.effectView.contentView.bounds
        self.highlightView = UIView(frame: highlightEffectView.contentView.bounds)
        self.highlightView.backgroundColor = UIColor(white: 1.0, alpha: 0.2)
        self.highlightView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.highlightView.alpha = 0.0
        
        highlightEffectView.contentView.addSubview(self.highlightView)
        self.effectView.contentView.addSubview(highlightEffectView)
        
        self.addTarget(self, action: #selector(didTouchDown(_:)), for: .touchDown)
        self.addTarget(self, action: #selector(didTouchDragExit(_:)), for: .touchDragExit)
        self.addTarget(self, action: #selector(didTouchDragEnter(_:)), for: .touchDragEnter)
        self.addTarget(self, action: #selector(didTouchUp(_:)), for: .touchUpInside)
        self.addTarget(self, action: #selector(didTouchUp(_:)), for: .touchUpOutside)
        self.addTarget(self, action: #selector(didTouchCancel(_:)), for: .touchCancel)
    
        //
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.15
        self.layer.shadowRadius = 4.0
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.masksToBounds = false
        //
        
        self.setTitleColor(self.tintColor, for: .normal)
        
        if #available(iOS 13.0, *) {
            let configuration = UIImage.SymbolConfiguration(pointSize: 15, weight: .heavy, scale: .small)
            let image = UIImage(systemName: "chevron.down", withConfiguration: configuration)?.withRenderingMode(.alwaysTemplate)
            self.setImage(image, for: .normal)
        }
        else {
            chevronView = PBChevronView(frame: CGRect(x: 4, y: 4.5, width: 16, height: 16))
            chevronView.width = 3.0
            chevronView.state = .up
            if let aView = chevronView {
                addSubview(aView)
            }
        }
    }
    
    private func setupForChevronButton() {
        chevronView = PBChevronView(frame: CGRect(x: 0, y: 0, width: 42, height: 15))
        chevronView.width = 5.5
        chevronView.state = .up
        if let aView = chevronView {
            addSubview(aView)
        }
    }
    
    // MARK: - Private Methods
    
    private func _setHighlighted(_ highlighted: Bool, animated: Bool) {
        let block = {
            self.highlightView?.alpha = highlighted ? 1.0 : 0.0
            self.highlightView?.alpha = highlighted ? 1.0 : 0.0
        }
        if animated {
            UIView.animate(withDuration: 0.47, delay: 0.0, options: .beginFromCurrentState, animations: {
                block()
            }, completion: nil)
        }
        else {
            block()
        }
    }
    
    /**
     :nodoc:
     */
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        if let effectView = self.effectView {
            self.sendSubviewToBack(effectView)
            effectView.frame = self.bounds
            
            let minSideSize: CGFloat = min(self.bounds.size.width, self.bounds.size.height)
            
            /*
            let maskLayer = CAShapeLayer()
            maskLayer.rasterizationScale = UIScreen.main.nativeScale
            maskLayer.shouldRasterize = true
            let path = CGPath(roundedRect: self.bounds, cornerWidth: minSideSize / 2, cornerHeight: minSideSize / 2, transform: nil)
            maskLayer.path = path
            effectView.layer.mask = maskLayer
            */
            
            effectView.clipsToBounds = true
            effectView.layer.cornerRadius = minSideSize / 2
            
            if let imageView = self.imageView {
                var imageFrame = imageView.frame
                imageFrame.origin.y += 0.5
                imageView.frame = imageFrame
            }
        }
    }
    
    /**
     :nodoc:
     */
    override public func sizeThatFits(_ size: CGSize) -> CGSize {
        if self.style == .round {
            return CGSize(width: 24.0, height: 24.0)
        }
        return CGSize(width: 42.0, height: 15.0)
    }
    
    /**
     :nodoc:
     */
    public override func tintColorDidChange() {
        self.setTitleColor(self.tintColor, for: .normal)
    }
    
    // MARK: - Public Methods
    
    @objc public func setButtonStateStationary() {
        if self.style == .round {
            return
        }
        self.chevronView.state = .up
    }
    
    @objc public func setButtonStateTransitioning() {
        if self.style == .round {
            return
        }
        self.chevronView.state = .flat
    }
    
    // MARK: - Actions
    
    @objc private func didTouchDown(_ sender: UIButton) {
        self._setHighlighted(true, animated: false)
    }
    
    @objc private func didTouchDragExit(_ sender: UIButton) {
        self._setHighlighted(false, animated: true)
    }
    
    @objc private func didTouchDragEnter(_ sender: UIButton) {
        self._setHighlighted(true, animated: true)
    }
    
    @objc private func didTouchUp(_ sender: UIButton) {
        self._setHighlighted(false, animated: true)
    }
    
    @objc private func didTouchCancel(_ sender: UIButton) {
        self._setHighlighted(false, animated: true)
    }
}
