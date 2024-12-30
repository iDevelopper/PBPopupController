//
//  UIView+Private.swift
//  PBPopupController
//
//  Created by Patrick BODET on 30/07/2022.
//  Copyright © 2022-2024 Patrick BODET. All rights reserved.
//

import UIKit
import Foundation
import ObjectiveC

//_backdropViewLayerGroupName
private let _bVLGN = "X2JhY2tkcm9wVmlld0xheWVyR3JvdXBOYW1l"

internal extension UIView
{
    var isMostlyVisible: Bool {
        guard !isHidden,
              alpha > 0,
              !bounds.isEmpty,
              let window,
              window.hitTest(window.convert(center, from: self.superview), with: nil) == self else {
            return false
        }
        return true
    }
    
    func superview<T:UIView>(ofType aType:T.Type) -> T? {
        var inputView: UIView? = self
        while inputView != nil {
            guard let view = inputView else { continue }
            inputView = view.superview
            if inputView == nil {
                return nil
            }
            if inputView is T {
                return inputView as? T
            }
        }
        return nil
    }

    func subviews<T:UIView>(ofType aType:T.Type) -> [T] {
        var result = self.subviews.compactMap {$0 as? T}
        for sub in self.subviews {
            result.append(contentsOf: sub.subviews(ofType:aType))
        }
        return result
    }
    
    var _effectGroupingIdentifierIfAvailable: String? {
        var key: String? = nil
        //DispatchQueue.once {
            key = _PBPopupDecodeBase64String(base64String: _bVLGN)
        //}
        if let key = key {
            if self.responds(to: NSSelectorFromString(key)) {
                return self.value(forKey: key) as? String
            }
            return nil
        }
        return nil
    }
}

internal extension UIScrollView
{
    var _pb_adjustedBounds: CGRect
    {
        return self.bounds.inset(by: self.adjustedContentInset)
    }

    var _pb_hasHorizontalContent: Bool
    {
        let rv = self.contentSize.width > self._pb_adjustedBounds.size.width
        return rv
    }

    var _pb_hasVerticalContent: Bool
    {
        let rv = self.contentSize.height > self._pb_adjustedBounds.size.height
        return rv
    }

    func _pb_scrollingOnlyVertically() -> Bool
    {
        return self._pb_hasHorizontalContent == false || self.panGestureRecognizer.translation(in: self).x == 0
    }

    func _pb_isAtTop() -> Bool
    {
        return self.contentOffset.y <= -self.adjustedContentInset.top
    }

}

