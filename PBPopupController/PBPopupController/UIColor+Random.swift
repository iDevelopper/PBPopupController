//
//  UIColor+Random.swift
//  PBPopupController
//
//  Created by Patrick BODET on 03/05/2018.
//  Copyright © 2018 Patrick BODET. All rights reserved.
//

import UIKit

/**
 A UIColor's extension that provides random colors.
 */
public extension UIColor {

    @objc public class func PBRandomDarkColor() -> UIColor? {
        let hue: CGFloat = CGFloat(arc4random() % 256) / 256
        let saturation: CGFloat = 0.5
        let brightness: CGFloat = 0.1 + CGFloat(arc4random() % 64) / 256
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1)
    }
    
    @objc public class func PBRandomLightColor() -> UIColor? {
        let hue: CGFloat = CGFloat(arc4random() % 256) / 256
        let saturation: CGFloat = 0.5
        let brightness: CGFloat = 1.0 - CGFloat(arc4random() % 64) / 256
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1)
    }
    
    @objc public class func PBRandomExtraLightColor() -> UIColor? {
        let hue: CGFloat = CGFloat(arc4random() % 256) / 256
        let saturation: CGFloat = 0.25
        let brightness: CGFloat = 1.0 - CGFloat(arc4random() % 32) / 256
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1)
    }
    
    @objc public class func PBRandomColor() -> UIColor {
        let hue : CGFloat = CGFloat(arc4random() % 256) / 256 // use 256 to get full range from 0.0 to 1.0
        let saturation : CGFloat = CGFloat(arc4random() % 128) / 256 + 0.5 // from 0.5 to 1.0 to stay away from white
        let brightness : CGFloat = CGFloat(arc4random() % 128) / 256 + 0.5 // from 0.5 to 1.0 to stay away from black
        
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1)
    }
}
