//
//  PBPopupState.swift
//  PBPopupController
//
//  Created by Patrick BODET on 08/10/2020.
//  Copyright © 2020-2022 Patrick BODET. All rights reserved.
//

import SwiftUI
import UIKit

@available(iOS 14.0, *)
internal struct PBPopupBarCustomView {
    let popupBarCustomBarView: AnyView
}

@available(iOS 14.0, *)
internal struct PBPopupState<PopupContent: View> {
    @Binding var isPresented: Bool
    @Binding var isOpen: Bool
    @Binding var isHidden: Bool
    let closeButtonStyle: PBPopupCloseButtonStyle
    let isFloating: Bool
    let popupBarStyle: PBPopupBarStyle
    var barStyle: UIBarStyle
    var backgroundStyle: UIBlurEffect.Style
    var backgroundEffect: UIBlurEffect?
    var floatingBackgroundEffect: UIBlurEffect?
    let inheritsVisualStyleFromBottomBar: Bool
    let isTranslucent: Bool
    let backgroundColor: UIColor?
    let floatingBackgroundColor: UIColor?
    let tintColor: UIColor?
    let progressViewStyle: PBPopupBarProgressViewStyle
    let borderViewStyle: PBPopupBarBorderViewStyle
    let shouldExtendCustomBarUnderSafeArea: Bool
    var customBarView: PBPopupBarCustomView?
    let popupPresentationStyle: PBPopupPresentationStyle
    let popupPresentationDuration: TimeInterval
    let popupDismissalDuration: TimeInterval
    let popupCompletionThreshold: CGFloat
    let popupCompletionFlickMagnitude: CGFloat
    let popupContentSize: CGSize
    let popupIgnoreDropShadowView: Bool
    let popupContent: (() -> PopupContent)?
    let popupContentViewController: UIViewController?
    let barCustomizer: ((PBPopupBar) -> Void)?
    let willPresent: (() -> Void)?
    let onPresent: (() -> Void)?
    let willDismiss: (() -> Void)?
    let onDismiss: (() -> Void)?
    let willOpen: (() -> Void)?
    let onOpen: (() -> Void)?
    let willClose: (() -> Void)?
    let onClose: (() -> Void)?
}
