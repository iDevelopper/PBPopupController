//
//  PBPopupRoundShadowImageView.swift
//  PBPopupController
//
//  Created by Patrick BODET on 18/11/2018.
//  Copyright © 2018-2020 Patrick BODET. All rights reserved.
//

import UIKit

/**
 A custom view that provide a shadow's layer arround an image view with a corner radius.
 */
@objc public class PBPopupRoundShadowImageView: UIView {

    // MARK: - Public Properties
    
    let imageView = UIImageView()

    @objc internal var image: UIImage! {
        didSet {
            imageView.image = image
            layoutView()
        }
    }
    
    @objc public var cornerRadius: CGFloat = 0.0 {
        didSet {
            imageView.layer.cornerRadius = cornerRadius
        }
    }
    
    @objc public var shadowColor: UIColor = UIColor.black {
        didSet {
            layer.shadowColor = shadowColor.cgColor
        }
    }
    
    @objc public var shadowOffset: CGSize = CGSize(width: 0.0, height: 0.0) {
        didSet {
            layer.shadowOffset = shadowOffset
        }
    }
    
    @objc public var shadowOpacity: Float = 0.0 {
        didSet {
            layer.shadowOpacity = Float(shadowOpacity)
        }
    }

    @objc public var shadowRadius: CGFloat = 0.0 {
        didSet {
            layer.shadowRadius = shadowRadius
        }
    }

    // MARK: - Init
    
    @objc internal override init(frame: CGRect) {
        super.init(frame: frame)
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(imageView)
        imageView.frame = bounds
    }
    
    @objc required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /**
     :nodoc:
     */
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        layoutView()
    }
    
    // MARK: - Private Methods
    
    private func layoutView() {
        layer.backgroundColor = UIColor.clear.cgColor
        layer.shadowColor = shadowColor.cgColor
        layer.shadowOffset = shadowOffset
        layer.shadowOpacity = Float(shadowOpacity)
        layer.shadowRadius = shadowRadius
        
        imageView.layer.cornerRadius = cornerRadius
        imageView.layer.masksToBounds = true
        
        imageView.contentMode = .scaleAspectFit
    }
}
