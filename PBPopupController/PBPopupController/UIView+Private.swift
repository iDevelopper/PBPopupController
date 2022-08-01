//
//  UIView+Private.swift
//  PBPopupController
//
//  Created by Patrick BODET on 30/07/2022.
//  Copyright © 2022 Patrick BODET. All rights reserved.
//

import UIKit
import Foundation

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
}
