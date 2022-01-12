//
//  UIScreen+ScreenCorners.swift
//  PBPopupController
//
//  Created by Patrick BODET on 06/09/2021.
//  Copyright © 2021-2022 Patrick BODET. All rights reserved.
//

import UIKit

//_displayCornerRadius
private let _dCR = "X2Rpc3BsYXlDb3JuZXJSYWRpdXM="

extension UIScreen {
    /*
    private static let cornerRadiusKey: String = {
        let components = ["Radius", "Corner", "display", "_"]
        return components.reversed().joined()
    }()
    */
    
    private static let cornerRadiusKey: String = {
        return _PBPopupDecodeBase64String(base64String: _dCR)!
    }()

    /// The corner radius of the display. Uses a private property of `UIScreen`,
    /// and may report 0 if the API changes.
    public var displayCornerRadius: CGFloat {
        guard let cornerRadius = self.value(forKey: Self.cornerRadiusKey) as? CGFloat else {
            return 0
        }

        return cornerRadius
    }
}
