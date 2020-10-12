//
//  PBPopupState.swift
//  PBPopupController
//
//  Created by Patrick BODET on 08/10/2020.
//  Copyright © 2020 Patrick BODET. All rights reserved.
//

import SwiftUI
import UIKit

@available(iOS 13.0, *)
internal struct PBPopupBarCustomView {
    let popupBarCustomBarView: AnyView
}

@available(iOS 13.0, *)
internal struct PBPopupState<PopupContent: View> {
    @Binding var isPresented: Bool
    @Binding var isOpen: Bool
    let closeButtonStyle: PBPopupCloseButtonStyle
    var popupBarStyle: PBPopupBarStyle
    let progressViewStyle: PBPopupBarProgressViewStyle
    let borderViewStyle: PBPopupBarBorderViewStyle
    var customBarView: PBPopupBarCustomView?
    let popupPresentationStyle: PBPopupPresentationStyle
    let popupPresentationDuration: TimeInterval
    let popupDismissalDuration: TimeInterval
    let popupCompletionThreshold: CGFloat
    let popupCompletionFlickMagnitude: CGFloat
    let popupContentSize: CGSize
    let popupContent: (() -> PopupContent)?
    let popupContentViewController: UIViewController?
    let onPresent: (() -> Void)?
    let onDismiss: (() -> Void)?
    let onOpen: (() -> Void)?
    let onClose: (() -> Void)?
}
