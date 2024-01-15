//
//  UIView+Private.swift
//  PBPopupController
//
//  Created by Patrick BODET on 30/07/2022.
//  Copyright © 2022-2024 Patrick BODET. All rights reserved.
//

import UIKit
import Foundation

//_backdropViewLayerGroupName
private let _bVLGN = "X2JhY2tkcm9wVmlld0xheWVyR3JvdXBOYW1l"

internal extension UIView
{
    func popupContentViewFor(_ view: UIView) -> PBPopupContentView?
    {
        var inputView: UIView? = view
        while inputView != nil {
            guard let view = inputView else { continue }
            inputView = view.superview
            if inputView == nil {
                return nil
            }
            if inputView is PBPopupContentView {
                return inputView as? PBPopupContentView
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
