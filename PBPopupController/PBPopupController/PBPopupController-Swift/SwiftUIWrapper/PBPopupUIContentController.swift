//
//  PBPopupUIContentController.swift
//  PBPopupController
//
//  Created by Patrick BODET on 07/10/2020.
//  Copyright © 2020-2022 Patrick BODET. All rights reserved.
//

import SwiftUI
import UIKit

@available(iOS 14.0, *)
internal class PBPopupUIContentController<Content> : UIHostingController<Content> where Content: View {
    
    override public var preferredStatusBarStyle: UIStatusBarStyle {
        guard let containerVC = self.popupContainerViewController else {return.default}
        guard let popupContentView = containerVC.popupContentView else {return .default}
        
        if popupContentView.popupPresentationStyle != .deck {
            return .default
        }
        return containerVC.popupController.popupStatusBarStyle
    }
}
