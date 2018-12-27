//
//  UIView+CornerRadius.swift
//  PBPopupController
//
//  Created by Patrick BODET on 29/11/2018.
//  Copyright © 2018 Patrick BODET. All rights reserved.
//

import UIKit
import Foundation

internal extension UIView
{
    internal func setupCornerRadiusTo(_ cornerRadius: CGFloat, rect: CGRect) {
        if #available(iOS 11.0, *) {
            self.layer.cornerRadius = CGFloat(cornerRadius)
            self.clipsToBounds = true
            self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else {
            let path = self.bezierWithRadius(rect: CGRect(x: 0.0, y: 0.0, width: rect.width, height: rect.height), radius: cornerRadius > 0.0 ? cornerRadius : 0.01)
            let maskLayer = CAShapeLayer()
            maskLayer.frame = CGRect(x: 0.0, y: 0.0, width: rect.width, height: rect.height)
            maskLayer.path = path.cgPath
            
            self.layer.mask = maskLayer
        }
    }
    
    internal func updateCornerRadiusTo(_ cornerRadius: CGFloat, rect: CGRect) {
        if #available(iOS 11.0, *) {
            self.layer.cornerRadius = CGFloat(cornerRadius)
            self.clipsToBounds = true
            self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else {
            let path = self.bezierWithRadius(rect: CGRect(x: 0.0, y: 0.0, width: rect.width, height: rect.height), radius: cornerRadius > 0.0 ? cornerRadius : 0.01)
            (self.layer.mask as! CAShapeLayer).path = path.cgPath
        }
    }
    
    private func bezierWithRadius(rect: CGRect, radius: CGFloat) -> UIBezierPath {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: radius, height: 0))
        return path
    }
}
