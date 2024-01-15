//
//  NSLayoutConstraint+Private.swift
//  PBPopupController
//
//  Created by Patrick BODET on 31/10/2021.
//  Copyright © 2021-2024 Patrick BODET. All rights reserved.
//

import Foundation
import UIKit

internal extension NSLayoutConstraint
{
    class func reportAmbiguity (_ v:UIView?) {
        var v = v
        if v == nil {
            v = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        }
        for vv in v!.subviews {
            print("\(vv) \(vv.hasAmbiguousLayout)")
            if vv.subviews.count > 0 {
                self.reportAmbiguity(vv)
            }
        }
    }
    class func listConstraints (_ v:UIView?) {
        var v = v
        if v == nil {
            v = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        }
        for vv in v!.subviews {
            let arr1 = vv.constraintsAffectingLayout(for:.horizontal)
            let arr2 = vv.constraintsAffectingLayout(for:.vertical)
            let s = String(format: "\n\n%@\nH: %@\nV:%@", vv, arr1, arr2)
            print(s)
            if vv.subviews.count > 0 {
                self.listConstraints(vv)
            }
        }
    }
}
