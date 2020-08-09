//
//  UIView+CornerRadius.swift
//  PBPopupController
//
//  Created by Patrick BODET on 29/11/2018.
//  Copyright © 2018-2020 Patrick BODET. All rights reserved.
//

import UIKit
import Foundation

internal enum PBPopupMaskedCorners : Int {
   case top
   case bottom
   case all
}

internal extension UIView
{
    func setupCornerRadiusTo(_ cornerRadius: CGFloat, rect: CGRect, maskedCorners: PBPopupMaskedCorners = .top) {
        if #available(iOS 11.0, *) {
            self.layer.cornerRadius = CGFloat(cornerRadius)
            self.clipsToBounds = true
            self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            if maskedCorners == .all {
                self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            }
        } else {
            let path = UIBezierPath.bezierPathWithRoundedRect(self.layer.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadius: cornerRadius)
            let maskLayer = CAShapeLayer()
            maskLayer.frame = self.layer.bounds
            maskLayer.path = path.cgPath
            self.layer.mask = maskLayer
        }
    }
    
    func updateCornerRadiusTo(_ cornerRadius: CGFloat, rect: CGRect, maskedCorners: PBPopupMaskedCorners = .top) {
        if #available(iOS 11.0, *) {
            self.layer.cornerRadius = CGFloat(cornerRadius)
            self.clipsToBounds = true
            self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            if maskedCorners == .all {
                self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            }
        } else {
            let path = UIBezierPath.bezierPathWithRoundedRect(CGRect(x: 0.0, y: 0.0, width: rect.width, height: rect.height), byRoundingCorners: [.topLeft, .topRight], cornerRadius: cornerRadius)
            self.animatePath(path)
        }
    }
    
    /*
    private func bezierWithRadius(rect: CGRect, radius: CGFloat) -> UIBezierPath {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: radius, height: 0))
        return path
    }
    */
    
    private func animatePath(_ path: UIBezierPath) {
        let animation = CABasicAnimation(keyPath: "path")
        animation.fromValue = (self.layer.mask as! CAShapeLayer).path
        animation.toValue = path.cgPath
        animation.fillMode = CAMediaTimingFillMode.backwards
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        (self.layer.mask as! CAShapeLayer).add(animation, forKey: "path")
        (self.layer.mask as! CAShapeLayer).path = path.cgPath
    }
}

extension UIBezierPath
{
    class func bezierPathWithRoundedRect(_ rect: CGRect, byRoundingCorners: UIRectCorner, cornerRadius: CGFloat) -> UIBezierPath {
        
        let path = UIBezierPath()
        
        // Top Left
        if byRoundingCorners.contains(.topLeft) {
            path.move(to: CGPoint(x: 0, y: cornerRadius))
            path.addQuadCurve(to: CGPoint(x: cornerRadius, y: 0), controlPoint: .zero)
        }
        else {
            let cornerPoint: CGPoint = .zero
            path.move(to: cornerPoint)
            path.addQuadCurve(to: cornerPoint, controlPoint: cornerPoint)
        }
        
        // Top Right
        if byRoundingCorners.contains(.topRight) {
            path.addLine(to: CGPoint(x: rect.width - cornerRadius, y: 0))
            path.addQuadCurve(to: CGPoint(x: rect.width, y: cornerRadius), controlPoint: CGPoint(x: rect.width, y: 0))
        }
        else {
            let cornerPoint = CGPoint(x: rect.width, y: 0)
            path.addLine(to: cornerPoint)
            path.addQuadCurve(to: cornerPoint, controlPoint: cornerPoint)
        }
        
        // Bottom Right
        if byRoundingCorners.contains(.bottomRight) {
            path.addLine(to: CGPoint(x: rect.width, y: rect.height - cornerRadius))
            path.addQuadCurve(to: CGPoint(x: rect.width - cornerRadius, y: rect.height), controlPoint: CGPoint(x: rect.width, y: rect.height))
        }
        else {
            let cornerPoint = CGPoint(x: rect.width, y: rect.height)
            path.addLine(to: cornerPoint)
            path.addQuadCurve(to: cornerPoint, controlPoint: cornerPoint)
        }
        
        // Bottom Left
        if byRoundingCorners.contains(.bottomLeft) {
            path.addLine(to: CGPoint(x: cornerRadius, y: rect.height))
            path.addQuadCurve(to: CGPoint(x: 0, y: rect.height - cornerRadius), controlPoint: CGPoint(x: 0, y: rect.height))
        }
        else {
            let cornerPoint = CGPoint(x: 0, y: rect.height)
            path.addLine(to: cornerPoint)
            path.addQuadCurve(to: cornerPoint, controlPoint: cornerPoint)
        }

        path.close()
        return path
    }
}
