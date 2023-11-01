//
//  UIColor+Random.swift
//  PBPopupController
//
//  Created by Patrick BODET on 03/05/2018.
//  Copyright © 2018-2023 Patrick BODET. All rights reserved.
//

import UIKit

/**
 A UIColor's extension that provides random colors.
 */
public extension UIColor
{
    @objc class func PBRandomDarkColor() -> UIColor? {
        let hue: CGFloat = CGFloat(arc4random() % 256) / 256
        let saturation: CGFloat = 0.5
        let brightness: CGFloat = 0.1 + CGFloat(arc4random() % 64) / 256
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1)
    }
    
    @objc class func PBRandomLightColor() -> UIColor? {
        let hue: CGFloat = CGFloat(arc4random() % 256) / 256
        let saturation: CGFloat = 0.5
        let brightness: CGFloat = 1.0 - CGFloat(arc4random() % 64) / 256
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1)
    }
    
    @objc class func PBRandomExtraLightColor() -> UIColor? {
        let hue: CGFloat = CGFloat(arc4random() % 256) / 256
        let saturation: CGFloat = 0.25
        let brightness: CGFloat = 1.0 - CGFloat(arc4random() % 32) / 256
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1)
    }
    
    @objc class func PBRandomColor() -> UIColor {
        let hue : CGFloat = CGFloat(arc4random() % 256) / 256 // use 256 to get full range from 0.0 to 1.0
        let saturation : CGFloat = CGFloat(arc4random() % 128) / 256 + 0.5 // from 0.5 to 1.0 to stay away from white
        let brightness : CGFloat = CGFloat(arc4random() % 128) / 256 + 0.5 // from 0.5 to 1.0 to stay away from black
        
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1)
    }
    
    @available(iOS 13.0, *)
    @objc class func PBRandomAdaptiveColor() -> UIColor {
        let lightColor = UIColor.PBRandomLightColor()
        let darkColor = UIColor.PBRandomDarkColor()
        
        return UIColor { (traitCollection) -> UIColor in
            if traitCollection.userInterfaceStyle == .dark {
                return darkColor!
            }
            else {
                return lightColor!
            }
        }
    }
    
    @available(iOS 13.0, *)
    @objc class func PBRandomAdaptiveInvertedColor() -> UIColor {
        let lightColor = UIColor.PBRandomLightColor()
        let darkColor = UIColor.PBRandomDarkColor()
        
        return UIColor { (traitCollection) -> UIColor in
            if traitCollection.userInterfaceStyle == .dark {
                return lightColor!
            }
            else {
                return darkColor!
            }
        }
    }
}

public extension UIColor {
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        
        let v = Int("000000" + hex, radix: 16) ?? 0
        let r = CGFloat(v / Int(powf(256, 2)) % 256) / 255
        let g = CGFloat(v / Int(powf(256, 1)) % 256) / 255
        let b = CGFloat(v / Int(powf(256, 0)) % 256) / 255
        self.init(red: r, green: g, blue: b, alpha: min(max(alpha, 0), 1))
    }

    convenience init(color: UIColor, alpha: CGFloat = 1.0) {
        var hex: String = "000000"
        if let rgb = color.cgColor.components {
            let r: CGFloat = rgb[0]
            let g: CGFloat = rgb[1]
            let b: CGFloat = rgb[2]
            
            hex = String.init(format: "%02lX%02lX%02lX", lroundf(Float(r * 255)), lroundf(Float(g * 255)), lroundf(Float(b * 255)))
        }
        self.init(hex: hex, alpha: alpha)
    }

    func lighterColor(value: CGFloat) -> UIColor {
        var h: CGFloat = 0
        var s: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0

        guard getHue(&h, saturation: &s, brightness: &b, alpha: &a) else { return self }

        let hsl = hsbToHsl(h: h, s: s, b: b)
        let hsb = hslToHsb(h: hsl.h, s: hsl.s, l: hsl.l + value)

        return UIColor(hue: hsb.h, saturation: hsb.s, brightness: hsb.b, alpha: a)
    }

    func darkerColor(value: CGFloat) -> UIColor {
        var h: CGFloat = 0
        var s: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0

        guard getHue(&h, saturation: &s, brightness: &b, alpha: &a) else { return self }

        let hsl = hsbToHsl(h: h, s: s, b: b)
        let hsb = hslToHsb(h: hsl.h, s: hsl.s, l: hsl.l - value)

        return UIColor(hue: hsb.h, saturation: hsb.s, brightness: hsb.b, alpha: a)
    }

    private func hsbToHsl(h: CGFloat, s: CGFloat, b: CGFloat) -> (h: CGFloat, s: CGFloat, l: CGFloat) {

        let newH = h
        var newL = (2.0 - s) * b
        var newS = s * b
        newS /= (newL <= 1.0 ? newL : 2.0 - newL)
        newL /= 2.0
        return (h: newH, s: newS, l: newL)
    }

    private func hslToHsb(h: CGFloat, s: CGFloat, l: CGFloat) -> (h: CGFloat, s: CGFloat, b: CGFloat) {
        let newH = h
        let ll = l * 2.0
        let ss = s * (ll <= 1.0 ? ll : 2.0 - ll)
        let newB = (ll + ss) / 2.0
        let newS = (2.0 * ss) / (ll + ss)
        return (h: newH, s: newS, b: newB)
    }
}
