//
//  PBPopupRoundShadowImageView.swift
//  PBPopupController
//
//  Created by Patrick BODET on 18/11/2018.
//  Copyright © 2018-2023 Patrick BODET. All rights reserved.
//

import UIKit

/**
 A custom view that provide a shadow's layer arround an image view with a corner radius.
 */
@objc open class PBPopupRoundShadowImageView: UIView {
    
    // MARK: - Public Properties
    
    public let imageView = UIImageView()
    
    /**
     The popup content view.
     
     - SeeAlso: `PBPopupContentView`.
     */
    @objc public var popupContentView: PBPopupContentView? {
        return self.popupContentViewFor(self)
    }
    
    @objc public var image: UIImage! {
        didSet {
            imageView.image = image
        }
    }
    
    @objc public var cornerRadius: CGFloat = 3.0 {
        didSet {
            imageView.layer.cornerRadius = cornerRadius
            if #available(iOS 13.0, *) {
                imageView.layer.cornerCurve = .continuous
            }
            imageView.layer.masksToBounds = true
        }
    }
    
    @objc public var shadowColor: UIColor? {
        get {
            return UIColor(cgColor: layer.shadowColor ?? UIColor.black.cgColor)
        }
        set(newValue) {
            layer.shadowColor = newValue?.cgColor
        }
    }
    
    @objc public var shadowOffset: CGSize = CGSize(width: 0.0, height: 3.0) {
        didSet {
            layer.shadowOffset = shadowOffset
        }
    }
    
    @objc public var shadowOpacity: Float = 0.5 {
        didSet {
            layer.shadowOpacity = Float(shadowOpacity)
        }
    }
    
    @objc public var shadowRadius: CGFloat = 3.0 {
        didSet {
            layer.shadowRadius = shadowRadius
        }
    }
    
    // MARK: - Init
    
    @objc public override init(frame: CGRect) {
        super.init(frame: frame)
        self.clipsToBounds = false
        addSubview(imageView)
        imageView.frame = bounds
    }
    
    @objc convenience public init(image: UIImage, cornerRadius: CGFloat = 0.0, shadowColor: UIColor = UIColor.black, shadowOffset: CGSize = .zero, shadowOpacity: Float = 0.0, shadowRadius: CGFloat = 0.0) {
        self.init(frame: .zero)
        
        self.image = image
        self.cornerRadius = cornerRadius
        self.shadowColor = shadowColor
        self.shadowOffset = shadowOffset
        self.shadowOpacity = shadowOpacity
        self.shadowRadius = shadowRadius
    }

    @objc required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /**
     :nodoc:
     */
    @objc open override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.frame = bounds
    }
}
